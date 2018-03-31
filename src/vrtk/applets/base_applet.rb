require 'bundler'

require_relative '../../vrtk'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class BaseApplet
		def initialize(argv = ARGV)
			@argv = argv

			@applet = {
				name: self.class.name,
				id:   self.class.id,
				desc: self.class.desc,

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