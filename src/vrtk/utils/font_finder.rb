require_relative '../../vrtk'
require_relative 'utils'
require_relative 'resource_finder'

require 'ostruct'
require 'logger'

module VRTK::Utils

	class FontFinderError < VRTK::VRTKError;
	end

	class FontFinder

		include VRTK

		DEFAULT_DIRS = ['.', File.dirname(__FILE__)]

		def initialize
			#
		end

		def self.find_font(name)
			if ENV['OS'].downcase.strip.start_with? 'windows'
				begin
					return find_font_windows name
				rescue FontFinderError
					return find_font_resources name
				end
			else
				raise FontFinderError, "couldn't find font '#{name}'"
			end
		end

		def self.find_font_resources(name)
			res = ResourceFinder.find_resources "*#{name}*.ttf"
			res += ResourceFinder.find_resources "fonts/*#{name}*.ttf"

			raise FontFinderError, "couldn't find font '#{name}'" unless res.size > 0

			(File.absolute_path(res[0]))
				.gsub(':', '\\:')
		end

		private

		def self.find_font_windows(name)
			dirs = DEFAULT_DIRS
			dirs << (Utils.to_upath "#{ENV['WINDIR']}\\Fonts")

			files = []

			dirs.each do |dir|
				files = Dir["#{dir}/*#{name}*.ttf"]
				break if files.size > 0
			end

			raise FontFinderError, "couldn't find font '#{name}'" unless files.size > 0

			(File.absolute_path(files[0]))
				.gsub(':', '\\:')
		end
	end
end
