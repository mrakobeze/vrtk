require 'fileutils'
require 'tmpdir'

UNWANTED_GEMS = %w(bundler rake)

module Packager
	class GemResolver
		attr_reader :files


		def initialize(rake: FileUtils)
			@files = []
			@rake = rake
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
			dir = Dir.mktmpdir(%w(VRTK.Build-- --gem_resolver))

			@rake.cp_r 'vendor/bundle', dir

			@rake.cd "#{dir}/bundle/ruby" do
				@rake.cd "#{Dir['*'].first}/gems" do
					@files = Dir['*']
						         .select do |gem|
						want = true
						UNWANTED_GEMS.each do |excl|
							if gem.strip.start_with? excl
								want = false
								break
							end
						end

						want
					end.map { |v| File.absolute_path v }
				end
			end
		end
	end
end
