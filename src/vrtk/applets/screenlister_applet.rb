require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../clipper/video_clipper'
require_relative '../collager/collager'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class ScreenlisterApplet < BaseApplet
		def init_options

			@options = OpenStruct.new({})

			OptionParser.new do |opts|

				opts.banner = "-== #{self.class.name} ==-\n#{self.class.desc}\nUsage: #{File.basename($PROGRAM_NAME)} #{self.class.id} [options]"

				opts.on('-?', '--help', 'This message') do |_|
					puts opts
					exit 0
				end

				opts.on('-i', '--input <file>', 'File to get previews from') do |v|
					@options.input = v
				end


			end
		end

		def run

			raise VRTK::Clipper::ClipperError, 'no input file specified!' unless @options.input

			VRTK::VideoClipper.new(
				input_file:  @options.input,
				clips_count: @options.count,
				output_dir:  @options.output_dir,
				font_size:   @options.font_size,
				logger:      Logger.new(STDERR, level: (@options.silent ? Logger::Severity::FATAL : Logger::Severity::INFO))
			)
				.perform

		end

		def self.name
			'VideoClipper applet'
		end

		def self.desc
			'Extracts screenshots from video.'
		end

		def self.id
			'clipper'
		end
	end
end