require 'fileutils'
require_relative '../bin_dep/url_resolver'
require_relative '../bin_dep/dep_manager'
require_relative '../utils'
require_relative 'gem_resolver'

module Packager
	class WindowsBuilder

		include Utils

		PKG_DIR = 'pkg'

		OUTPUT_DIR = "#{PKG_DIR}/windows"
		SRC_DIR    = 'ruby'
		RES_DIR    = 'res'
		EXT_DIR    = "lib/ruby/#{Utils.ruby_version}/x64-mingw32"
		BUNDLE_DIR = 'lib/'

		RUBY_DIR     = 'dist/ruby'
		SRC_DIRS     = %w(bin src)
		RES_DIRS     = %w(data)
		EXT_DIRS     = %w(ext)
		BINDEPS_DIR  = 'dist/bindeps'
		BINDEPS_FILE = "#{BINDEPS_DIR}/bindeps.yml"
		WRAPPER_FILE = 'dist/wrapper/template.cmd'

		# include FileUtils

		def initialize(logger: nil, dsl:)
			@logger = logger
			@dsl    = dsl
		end

		def self.build_task
			'windows:build:all'
		end

		def create_tasks
			@dsl.namespace :windows do
				@dsl.namespace :build do
					# region Global tasks
					@dsl.desc 'Make build directory tree'
					@dsl.task :dirs do
						mkdirs
					end
					@dsl.desc 'Copy everything to package'
					@dsl.task :all do
						package
					end
					# endregion
					# region Single-copy tasks
					@dsl.namespace :copy do
						(self.methods - self.class.methods)
							.map(&:to_s)
							.grep(/^copy/)
							.each do |task|
							task_name   = task.split('_').last.to_sym
							method_name = task.to_sym
							@dsl.desc "Copy #{task_name.to_s} to package"
							@dsl.task task_name do
								mkdirs
								self.public_send method_name
							end
						end
					end
					# endregion
				end
			end
		end

		def copy_bindeps
			@resolver = BinDep::URLResolver.create 'https://dist.nuklearcorp.com/misc/%{depname}.zip', logger: @logger
			@logger.info 'copying bindeps'
			BinDep::DepManager.new(file: BINDEPS_FILE).load
				.each do |bindep|
				@logger.info "resolving '#{bindep.name}'"

				status = @resolver.resolve bindep

				case (status)
					when BinDep::BaseResolver::Status::FAILED
						@logger.error "failed to resolve bindep '#{bindep.name}'"
					when BinDep::BaseResolver::Status::RESOLVED
						@logger.info "resolved bindep '#{bindep.name}'"
					when BinDep::BaseResolver::Status::EXISTS
						@logger.info "no need to resolve bindep '#{bindep.name}' - exists"
					else
						# type code here
				end

				@logger.info "installing #{bindep.name}"

				depdir = "#{BINDEPS_DIR}/#{bindep.name}"

				mkdir_p "#{OUTPUT_DIR}/#{bindep.install_to}"

				bindep.files
					.map { |v| [File.absolute_path("#{depdir}/#{v}"), File.absolute_path("#{OUTPUT_DIR}/#{bindep.install_to}/#{v}")] }
					.each do |from, to|
					@logger.debug "copying #{from}"
					if File.directory?(from) and File.exists?(to)
						rm_rf to unless File.directory? to

						Dir["#{from}/*"]
							.map { |f| File.absolute_path f }
							.each do |file|
							cp_r file, to
						end
					else
						to = "#{to}/#{File.basename from}" if not File.directory? from and File.directory? to
						rm_rf to
						cp_r from, to
					end
				end
			end
		end

		def copy_sources
			@logger.info 'installing sources'
			SRC_DIRS.each do |dir|
				@logger.debug "copying #{dir}"

				file = File.absolute_path(dir)
				cp_r file, "#{OUTPUT_DIR}/#{SRC_DIR}"
			end
		end

		def copy_resources
			@logger.info 'installing resources'
			RES_DIRS.each do |dir|
				@logger.debug "copying #{dir}"

				file = File.absolute_path(dir)
				cp_r file, "#{OUTPUT_DIR}/#{RES_DIR}"
			end
		end

		def copy_extensions
			@logger.info 'installing extensions'
			exts = []
			EXT_DIRS.each do |dir|
				exts += Dir["#{dir}/*"]
					        .map { |v| File.absolute_path v }
			end

			exts.each do |ext|
				@logger.debug "copying #{ext}"

				cp_r ext, "#{OUTPUT_DIR}/#{EXT_DIR}"
			end
		end


		def package
			mkdirs

			copy_bindeps
			copy_bundle

			copy_sources
			copy_extensions

			copy_resources

			copy_wrapper
		end

		def copy_bundle
			@logger.info 'resolving gem bundle'

			gems = GemResolver.new

			gems.install_gems
			gems.fetch_files

			@logger.info 'copying gem bundle'

			(gems.files).each do |file|
				@logger.debug "copying #{File.basename(file)}"

				cp_r file, "#{OUTPUT_DIR}/#{BUNDLE_DIR}"
			end
		end

		def copy_wrapper
			@logger.info 'installing wrapper'
			wrapper = IO.read(WRAPPER_FILE) % {
				res_dir: RES_DIR,
				src_dir: SRC_DIR,
			}

			IO.write "#{OUTPUT_DIR}/vrtk.cmd", wrapper
		end

		def mkdirs
			@logger.info 'making directory tree'
			mkdir_p OUTPUT_DIR
			mkdir_p "#{OUTPUT_DIR}/#{SRC_DIR}"
			mkdir_p "#{OUTPUT_DIR}/#{RES_DIR}"
			mkdir_p "#{OUTPUT_DIR}/#{EXT_DIR}"
		end

	end
end
