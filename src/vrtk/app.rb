require 'bundler'

require_relative 'config'
require_relative 'version'

Bundler.require :app

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
				STDERR.puts error.message.colorize :blue
				STDERR.puts 'Exited.'.colorize :blue
			end
		end

		def __exec

			opt_parse

			applet = ARGV.shift

			no_applet unless applet

			raise VRTKError, "Applet '#{applet}' is unavailable!" unless VRTK::Config::APPLETS[applet]

			applet = VRTK::Config::APPLETS[applet].new @argv

			applet.run
		end

		def opt_parse
			OptionParser.new do |opts|
				opts.banner = banner

				opts.on('-?', '--help', 'See this help') do |_|
					puts opts
					exit 0
				end

				opts.on('-v', '--version', 'Print version') do |_|
					puts "VRTK #{VRTK::VERSION}"
					exit 0
				end
			end.parse!
		end

		private

		def banner
			<<END
-== Video Releaser's toolkit ==- 
Usage: #{$PROGRAM_NAME} <applet> 
Applets:
#{get_applets}
Options:
END
		end

		def no_applet
			STDERR.print 'ERROR: '.colorize(:red)
			STDERR.puts "invalid usage!\nCall #{$0} --help.".colorize :blue
			exit 0
		end

		def get_applets
			text = []
			VRTK::Config::APPLETS.each do |_, applet|
				text << <<END
#{applet.id}
				#{applet.name}
				#{applet.desc}
END
			end

			text.join $\
		end
	end
end