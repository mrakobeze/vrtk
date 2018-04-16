require 'fileutils'
require 'zip'

module Utils
	class ZipperBase
		include FileUtils
	end

	class Zipper < ZipperBase
		def initialize(input_dir, output_file)
			@input_dir   = input_dir
			@output_file = output_file
		end

		def write(logger:)
			@logger = logger
			entries = Dir.entries(@input_dir) - %w(. ..)

			Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
				write_entries entries, '', zipfile
			end
		end

		private

		def write_entries(entries, path, zipfile)
			entries.each do |e|
				zipfile_path   = path == '' ? e : File.join(path, e)
				disk_file_path = File.join(@input_dir, zipfile_path)
				@logger.debug "deflating #{disk_file_path}"

				if File.directory? disk_file_path
					deflate_dir(disk_file_path, zipfile, zipfile_path)
				else
					put(disk_file_path, zipfile, zipfile_path)
				end
			end
		end

		def deflate_dir(disk_file_path, zipfile, zipfile_path)
			zipfile.mkdir zipfile_path
			subdir = Dir.entries(disk_file_path) - %w(. ..)
			write_entries subdir, zipfile_path, zipfile
		end

		def put(disk_file_path, zipfile, zipfile_path)
			zipfile.get_output_stream(zipfile_path) do |f|
				f.write(File.open(disk_file_path, 'rb').read)
			end
		end
	end

	class Unzipper < ZipperBase
		def initialize(input_file, output_dir)
			@if = input_file
			@od = output_dir
		end

		def extract(logger:)
			files = []

			mkdir_p @od

			Zip::File.open(@if) do |zip_file|
				zip_file.each do |entry|
					logger.debug "unzipper: inflating #{entry.name}"

					rm_rf "#{@od}/#{entry.name}"
					entry.extract("#{@od}/#{entry.name}")

					files << "#{@od}/#{entry.name}"
				end
			end

			files
		end
	end
end