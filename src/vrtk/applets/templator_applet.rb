require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../templator/templator'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets

	class TemplatorApplet < BaseApplet

		include VRTK
		include VRTK::Template

		WILDCARDS = "(wildcards allowed, '%' instead of '*', '\#' instead of '?')"

		def init_options

			@options = OpenStruct.new({
				                          files: []
			                          })

			OptionParser.new do |opts|

				opts.banner = "-== #{self.class.name} ==-\n#{self.class.desc}\nUsage: #{File.basename($PROGRAM_NAME)} #{self.class.id} [options]"

				opts.on('-?', '--help', 'This message') do |v|
					puts opts
					exit 0
				end

				opts.on('-a', '--add <filemask>', "Add files to collage #{WILDCARDS}") do |v|
					files          = Dir[Utils.to_wildcard(v)]
					@options.files += files
				end

				opts.on('-x', '--exclude <filemask>', "Exclude files from collage #{WILDCARDS}") do |v|
					files          = Dir[Utils.to_wildcard(v)]
					@options.files -= files
				end

				opts.on('-t', '--target <dir>', 'Directory where template will be generated.') do |v|
					@options.output = v
				end

				opts.on('', '--hd', 'Generate HD Video template instead of general-typed.') do |v|
					@options.hd = v
				end

				opts.on('-!', '--move', 'Move input videos instead of copying.') do |v|
					@options.move = v
				end

			end
		end

		def run

			VRTK::Templator.new(
				output_dir:  @options.output,
				hd:          @options.hd,
				move_input:  @options.move,
				video_files: @options.files
			)
				.perform
		end

		def self.name
			'Templator applet'
		end

		def self.desc
			'Generates template for video release'
		end

		def self.id
			'plato'
		end
	end

end