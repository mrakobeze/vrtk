require_relative '../../vrtk'
require_relative '../utils/utils'

require 'ostruct'
require 'logger'

module VRTK::Utils

	class ResourceFinderError < VRTK::VRTKError;
	end
	class ResourceFinder
		include VRTK::Utils
		include VRTK

		DEFAULT_DIRS = %w(. ./data ./res ./assets)

		def self.find_resources(wildcard)

			files = []

			res_dirs.each do |dir|
				files += Dir["#{dir}/#{wildcard}"] || []
			end

			raise ResourceFinderError, "Couldn't find any resources by wildcard '#{wildcard}'!" unless files.size > 0

			files
		end

		private
		def self.res_dirs
			dirs = DEFAULT_DIRS
			dirs << Utils.clean_path(ENV['VRTK_DATA_DIR']) unless ENV['VRTK_DATA_DIR'].nil?

			dirs
		end
	end
end