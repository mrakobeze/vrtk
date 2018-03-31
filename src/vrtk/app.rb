require_relative 'config'
require_relative 'version'

require 'colorize'
require 'optparse'

module VRTK
	class App
		def initialize(argv = ARGV)
			@argv = argv
		end

		def run
			begin
				__exec
			rescue VRTKError => error
				STDERR.print 'ERROR: '.colorize :red
				STDERR.puts error.message.colorize :light_blue
				STDERR.puts 'Exited.'.colorize :light_blue
			end
		end

		def __exec

			applet_help = opt_parse

			applet = ARGV.shift

			no_applet unless applet

			raise VRTKError, "Applet '#{applet}' is unavailable!" unless VRTK::Config::APPLETS[applet]

			applet = VRTK::Config::APPLETS[applet].new @argv

			applet.run
		end

		def opt_parse

		end

		private


		def no_applet
			STDERR.print 'ERROR: '.colorize(:red)
			STDERR.puts "invalid usage!\nCall #{File.basename($PROGRAM_NAME)} help.".colorize :light_blue
			exit 0
		end


	end
end