require 'fileutils'
require 'bundler'

include FileUtils

Bundler.require :dev

class Zipper
	# Initialize with the directory to zip and the location of the output archive.
	def initialize(input_dir, output_file)
		@input_dir   = input_dir
		@output_file = output_file
	end

	# Zip the input directory.
	def write
		entries = Dir.entries(@input_dir) - %w(. ..)

		::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
			write_entries entries, '', zipfile
		end
	end

	private

	# A helper method to make the recursion work.
	def write_entries(entries, path, zipfile)
		entries.each do |e|
			zipfile_path   = path == '' ? e : File.join(path, e)
			disk_file_path = File.join(@input_dir, zipfile_path)
			puts "deflating #{disk_file_path}"

			if File.directory? disk_file_path
				recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
			else
				put_into_archive(disk_file_path, zipfile, zipfile_path)
			end
		end
	end

	def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
		zipfile.mkdir zipfile_path
		subdir = Dir.entries(disk_file_path) - %w(. ..)
		write_entries subdir, zipfile_path, zipfile
	end

	def put_into_archive(disk_file_path, zipfile, zipfile_path)
		zipfile.get_output_stream(zipfile_path) do |f|
			f.write(File.open(disk_file_path, 'rb').read)
		end
	end
end

class Unzipper
	def initialize(input_file, output_dir)
		@if = input_file
		@od = output_dir
	end

	def extract(verbose: false)
		files = []

		mkdir_p @od

		Zip::File.open(@if) do |zip_file|
			zip_file.each do |entry|
				puts "inflating #{entry.name} -> #{@od}/#{entry.name}" if verbose

				rm_rf "#{@od}/#{entry.name}"
				entry.extract("#{@od}/#{entry.name}")

				files << "#{@od}/#{entry.name}"
			end
		end

		files
	end
end