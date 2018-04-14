require 'bundler'

require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../collager/collager'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets

	class CollagerApplet < BaseApplet

		include VRTK
		include VRTK::Collage

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

				opts.on('-l', '--file-limit <n>', "If specified, only first 'n' files are used.") do |v|
					@options.file_limit = v.to_i
				end

				opts.on('-r', '--tile-ratio <size>', "One tile's side ratio. If not specified, 16x9 ratio is used.") do |v|
					sz = v.split('x').map &:to_i

					raise CollagerError, 'Invalid ratio!' if sz.size != 2
					sz.each { |a| raise CollagerError, 'Invalid ratio!' unless a > 0 }

					@options.ratio = sz
				end

				opts.on('-o', '--output <file>', 'Output file. If not specified, out.jpeg is used.') do |v|
					@options.output = v
				end

				opts.on('-w', '--width <width>', 'Output collage width. If not specified, 1200 is used.') do |v|
					@options.width = v.to_i
				end

			end
		end

		def run

			raise CollagerError, 'no input file specified!' unless @options.files

			VRTK::Collager.new(
				input_files:   @options.files,
				output_file:   @options.output,
				tile_ratio:    @options.ratio,
				file_limit:    @options.file_limit,
				collage_width: @options.width
			)
				.perform
		end

		def self.name
			'Collager applet'
		end

		def self.desc
			'Generates grid-like collage from input images'
		end

		def self.id
			'collager'
		end
	end

end