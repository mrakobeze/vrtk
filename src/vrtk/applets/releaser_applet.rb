require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../releaser/releaser'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class ReleaserApplet < BaseApplet

		include VRTK

		def init_options
			OptionParser.new do |opts|
				opts.on('-f', '--font-size <size>', 'Specifies font size for VRTK.Clipper') do |v|
					@fs = v.to_i
				end
			end
		end

		def run
			Releaser.new(
				font_size: @fs
			).perform
		end

		def self.name
			'Releaser applet'
		end

		def self.id
			'release'
		end

		def self.desc
			'Creates a complete release within current template directory. Has no options now, will be fixed in next releases.'
		end

	end

end