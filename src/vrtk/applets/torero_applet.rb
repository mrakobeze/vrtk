require_relative '../../vrtk'
require_relative 'base_applet'
require_relative '../torero/torero'

require 'ostruct'
require 'optparse'
require 'logger'

module VRTK::Applets

	class ToreroApplet < BaseApplet

		include VRTK
		include VRTK::Torera

		WILDCARDS = "(wildcards allowed, '%' instead of '*', '\#' instead of '?')"

		def init_options

			@options = OpenStruct.new({
				                          files: [],
				                          dirs:  []
			                          })

			OptionParser.new do |opts|

				opts.banner = "-== #{self.class.name} ==-\n#{self.class.desc}\nUsage: #{File.basename($PROGRAM_NAME)} #{self.class.id} [options]"

				opts.on('-?', '--help', 'This message') do |v|
					puts opts
					exit 0
				end

				opts.on('-a', '--add <filemask>', "Add files to torrent #{WILDCARDS}") do |v|
					files          = Dir[Utils.to_wildcard(v)]
					@options.files += files
				end

				opts.on('-x', '--exclude <filemask>', "Exclude files from torrent #{WILDCARDS}") do |v|
					files          = Dir[Utils.to_wildcard(v)]
					@options.files -= files
				end

				opts.on('-d', '--add-dir <dir>', 'Add directory to torrent') do |v|
					raise ToreroError, "'#{v}' is not a directory!" unless File.directory? v
					@options.dirs << File.absolute_path(v)
				end

				opts.on('-o', '--output <file>', 'File to save torrent in.') do |v|
					@options.output = v
				end

				opts.on('-r', '--root', 'Set root directory (detected automatically in most cases)') do |v|
					@options.root = v
				end
			end
		end


		def run
			@options.files.map! { |v| File.absolute_path v }
			@options.dirs.map! { |v| File.absolute_path v }

			if @options.root.nil?
				paths = @options.files + @options.dirs
				root  = paths[0]
				paths.each do |path|
					root = common_prefix(root, path)
				end

				@options.root = root
			end

			worker = Torero.new(
				input_files: @options.files,
				input_dirs:  @options.dirs,
				output_file: @options.output,
				root:        @options.root
			)

			worker.perform
		end

		def self.name
			'Torero applet'
		end

		def self.desc
			'Generates torrent file'
		end

		def self.id
			'torero'
		end

		private

		def common_prefix(a, b)
			a.split('').zip(b.split(''))
				.take_while { |x, y| x == y }
				.map(&:first)
				.join('')
		end
	end

end