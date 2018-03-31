require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../clipper/video_clipper'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class ClipperApplet < BaseApplet
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

				opts.on('-n', '--count <n>', 'Number of previews that will be generated (+-1)') do |v|
					@options.count = v.to_i
				end

				opts.on('-f', '--font-size <n>', 'Font size for timestamp. If not specified, 200 is used.') do |v|
					@options.font_size = v.to_i
				end

				opts.on('-q', '--silent', 'Do not generate additional output') do |v|
					@options.silent = v
				end

				opts.on('-o', '--output <dir>', 'Dir where generated files will be stored') do |v|
					@options.output_dir = v
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