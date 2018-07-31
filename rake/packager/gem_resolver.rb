require 'fileutils'
require 'tmpdir'

UNWANTED_GEMS = %w(bundler rake)

module Packager
	class GemResolver
		attr_reader :files


		def initialize(rake: FileUtils)
			@files = []
			@rake  = rake
		end

		def install_gems
			return if File.exists? 'vendor'

			system %q[bundle install --deployment]

			unless File.exists? 'vendor'
				@rake.rm_rf '.bundle'
				system %q[bundle install]
				system %q[bundle install --deployment]
			end
		end

		def clean
			@rake.rm_rf '.bundle'
			@rake.rm_rf 'vendor'
		end

		def fetch_files
			# dir = Dir.mktmpdir(%w(VRTK.Build-- --gem_resolver))

			@files = [File.absolute_path('vendor/bundle')]
		end
	end
end
