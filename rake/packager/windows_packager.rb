require 'fileutils'

require_relative 'windows_builder'
require_relative '../utils'
require_relative '../inno/iss_generator'
require_relative '../../src/vrtk/version'

module Packager
	class WindowsPackager

		ZIP_FILE      = "vrtk_#{VRTK::CODENAME}_windows-x86_64.zip"
		TEMPLATE_FILE = 'dist/innosetup/template.iss'
		ISS_FILE      = 'tmp.iss'
		SETUP_FILE    = "vrtk_#{VRTK::CODENAME}_windows-x86_64"

		include Utils

		def initialize(logger:, dsl:)
			@build_task = WindowsBuilder.build_task
			@logger     = logger
			@dsl        = dsl
		end

		def create_tasks
			@dsl.namespace :windows do
				@dsl.namespace :package do
					@dsl.desc 'Make all packages'
					@dsl.task :all => [@build_task] do
						all
					end

					(self.methods - self.class.methods)
						.map(&:to_s)
						.grep(/^make/)
						.each do |task|
						task_name   = task.split('_').last.to_sym
						method_name = task.to_sym
						@dsl.desc "Make #{task_name.to_s} package"
						@dsl.task task_name => [@build_task] do
							self.public_send method_name
						end
					end
				end
			end
		end

		def make_zip
			input = WindowsBuilder::OUTPUT_DIR
			@logger.info 'making zip file'
			@logger.debug 'removing old zip'
			rm_rf ZIP_FILE
			Zipper.new(input, "#{WindowsBuilder::PKG_DIR}/#{ZIP_FILE}").write logger: @logger
		end

		def all
			make_zip
			make_installer
		end

		def make_installer
			iss = Inno::IssGenerator.new(TEMPLATE_FILE)
			iss.generate ISS_FILE, bind: {
				pkg_dir:   WindowsBuilder::PKG_DIR,
				input_dir: WindowsBuilder::OUTPUT_DIR,
				out_file:  SETUP_FILE,
				codename:  VRTK::CODENAME,
				version:   VRTK::VERSION
			}
			iss.build ISS_FILE
			rm_rf ISS_FILE
		end
	end
end