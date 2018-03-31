require_relative '../../vrtk'
require_relative '../utils/utils'

require 'ostruct'
require 'logger'

module VRTK::Clipper

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
				find_font_windows name
			else
				raise FontFinderError, "couldn't find font '#{name}'"
			end
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
