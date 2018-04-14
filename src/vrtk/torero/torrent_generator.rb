require 'time'

require 'bencode'

begin
	require 'hasher'
rescue Exception => e
	puts e.message
end

require_relative 'tg_assets'
require_relative '../version'

module VRTK::Torera

	class TorrentGenerator

		include VRTK

		include Assets

		attr_accessor :root

		def initialize
			@files = []
			@root  = ''
		end

		def add_files(files)
			@files += files.map do |file|
				if File.directory? file
					nil
				else
					File.absolute_path(file)
				end
			end.select { |f| not f.nil? }
		end

		def files
			@root = clean_path @root

			hash = {}

			@files.each do |file|
				orig = file.dup
				file = clean_path file
				if file.start_with? root
					file = file.slice(@root.size, file.size - @root.size)
				else
				end

				hash[orig] = file
					             .split(/[\/\\]+/)
					             .select { |v| v.size > 0 }
			end

			hash
		end

		# noinspection RubyStringKeysInHashInspection
		def template
			{
				'info'          => {
					'name' => File.basename(@root)
				},
				'creation date' => Time.now.to_i,
				'created by'    => "VRTK.Torero #{VRTK::VERSION}",
				'comment'       => 'video release'
			}
		end

		def generate
			hasher = Torrent::Hasher.new

			@files.each do |file|
				hasher.add_file file
			end

			hasher.eval

			p hasher.pieces_count

			hash                         = template
			hash['info']['piece length'] = hasher.piece_size
			hash['info']['pieces']       = (hasher.hash)

			files_asc = files

			# noinspection RubyStringKeysInHashInspection
			hash['info']['files'] = @files.map do |file|
				{
					'length' => File.size(file),
					'path'   => files_asc[file]
				}
			end

			hash.bencode
		end

		def add_folder(folder)
			dir = Dir.new folder

			files = []

			dir.each do |file|
				next if %w(.. .).include? file.strip
				file = File.absolute_path "#{folder}/#{file}"

				if File.directory? file
					add_folder file
				end

				files << file
			end

			add_files files
		end

	end
end