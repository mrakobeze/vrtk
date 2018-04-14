require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../metalyzer/metalyzer'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets
	class MetalyzerApplet < BaseApplet
		def init_options

			@options = OpenStruct.new({})

			OptionParser.new do |opts|

				opts.banner = "-== #{self.class.name} ==-\n#{self.class.desc}\nUsage: #{File.basename($PROGRAM_NAME)} #{self.class.id} [options]"

				opts.on('-?', '--help', 'This message') do |_|
					puts opts
					exit 0
				end

				opts.on('-i', '--input <file>', 'File to get meta from') do |v|
					@options.input = v
				end

				opts.on('-f', '--format <file>', %q[Output format: 'text' for text output and 'image' for JPEG output.]) do |v|
					raise VRTK::Metalyze::MetalyzerError, "Invalid format type '#{v}'" unless %w(image text).include? v.strip
					@options.format_s = v
				end

				opts.on('-o', '--output <file>', 'Output file') do |v|
					@options.output = v
				end

			end
		end

		def run

			raise VRTK::Metalyze::MetalyzerError, 'no input file specified!' unless @options.input

			logger = Logger.new(STDERR, level: (@options.silent ? Logger::Severity::FATAL : Logger::Severity::INFO))

			logger.formatter = proc do |sev, _, _, msg|
				%Q[VRTK:Clipper     | %s | %s\n\n] % [sev, msg]
			end

			begin
				VRTK::Metalyzer.new(
					input_file:  @options.input,
					output_file: @options.output,
					format:      @options.format_s
				)
					.perform
			rescue Exception => e
				raise VRTK::Clipper::ClipperError, e.message
			end
		end

		def self.name
			'Metalyzer applet'
		end

		def self.desc
			'Extracts short metadata from video to text file or image.'
		end

		def self.id
			'metal'
		end
	end
end