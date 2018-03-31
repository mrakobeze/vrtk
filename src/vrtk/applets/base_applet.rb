require 'bundler'

require_relative '../../vrtk'

Bundler.require :applets

module VRTK::Applets
	class BaseApplet
		def initialize(argv = ARGV)
			@argv = argv

			@applet = {
				name: name,
				id:   id,
				desc: desc,

			}

			op = init_options
			op.parse! argv
		end

		def init_options
			OptionParser.new do |opts|
				opts.banner = "#{@applet.name}\n#{@applet.desc}\n\nUsage: vrtk #{@applet.id} [options]"

				opts.on('-?', '--help') do |v|
					puts opts
				end
			end
		end

		def run
		end

		def self.name
			'Applet'
		end

		def self.id
			'applet'
		end
		def self.desc
			'The Applet gives no description.'
		end
	end
end