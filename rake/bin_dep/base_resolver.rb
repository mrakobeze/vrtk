require_relative '../utils'
require_relative 'bin_dep'

require 'tmpdir'

module BinDep

	class ResolverError < Exception;
	end

	class BaseResolver

		include Utils

		module Status
			RESOLVED = 0
			EXISTS   = 1
			FAILED   = 2
		end

		class InternalError < Exception;
		end

		def initialize(dist_dir: 'dist/bindeps/', logger:)
			@dist   = dist_dir
			@logger = logger
		end

		def resolve(dep)
			accept? dep

			files = []
			files = (dep.files)
				        .map(&:strip)
				        .map { |v| File.absolute_path "#{@dist}/#{dep.name}/#{v}" }
				        .uniq

			missing = false

			files.each do |file|
				next if File.exists? file
				@logger.debug "from #{dep.name} missing #{file}"
				missing = true
				break
			end


			return Status::EXISTS unless missing

			begin
				_resolve dep.name
			rescue InternalError => e
				raise ResolverError, e.message
			rescue TypeError => e
				raise e
			end

			missing = false

			files.each do |file|
				next if File.exists? file
				missing = true
				break
			end

			(missing ? Status::FAILED : Status::RESOLVED)
		end

		private

		def accept?(dep)
			accept = dep.respond_to?(:files) and dep.respond_to?(:name)
			raise TypeError, "invalid argument supplied to #{self.class}#resolve" unless accept
		end

		protected

		def _resolve(depname)
			url = get_url depname

			begin
				rm_rf "#{@dist}/#{depname}"

				tmpfile(prefix: 'VRTK.Build', suffix: depname) do |file|
					@logger.debug "GET #{url}"
					download url, target: file
					Unzipper.new(file, "#{@dist}/#{depname}").extract logger: @logger
				end
			rescue Exception => e
				puts e.backtrace
				raise InternalError, e.message
			end
		end


		def get_url(name)
			raise TypeError, "#{self.class}#get_url not implemented!"
		end

	end

end
