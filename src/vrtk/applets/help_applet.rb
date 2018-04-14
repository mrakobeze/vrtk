require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class HelpApplet < BaseApplet

		def init_options
			OptionParser.new do |opts|

			end
		end

		def run
			puts banner
		end

		def self.name
			'Help applet'
		end

		def self.id
			'help'
		end

		def self.desc
			'Displays this message'
		end

		private
		def banner
			"-==: Video Releaser's toolkit :==-\n Usage: #{File.basename($PROGRAM_NAME)} <applet>\n Applets:\n#{get_applets}"
		end

		def get_applets
			text = []
			VRTK::Config::APPLETS.each do |_, applet|
				text << <<END
#{applet.id}
				-= #{applet.name} =-
				#{applet.desc}
END
			end

			text.join $\
		end

	end

end