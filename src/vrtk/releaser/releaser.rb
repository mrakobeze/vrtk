require_relative '../utils/utils'
require_relative '../utils/ffmpeg'
require_relative '../utils/font_finder'
require_relative '../utils/resource_finder'
require_relative 'releaser_error'
require_relative '../clipper/video_clipper'
require_relative '../collager/collager'
require_relative '../metalyzer/metalyzer'

require 'json'
require 'ostruct'
require 'fileutils'
require 'tmpdir'
require 'logger'

class String
	def fitline(nfit = 35)
		lines = []
		s     = self.split ''
		st    = 0

		nfit = [nfit, self.size].min

		loop do
			break if st >= self.size
			fi = [(st + (nfit)), self.size].min

			ss = s[st...fi].join('')
			lines << "#{ss}"

			st = fi
		end

		lines.join("\\\\\n")
	end
end

module VRTK

	class Releaser

		include VRTK::Release
		include FileUtils

		def initialize(
			tpl_dir: nil,
			font_size: nil
		)

			@options = OpenStruct.new ({
				tpl_dir:   tpl_dir || '.',
				font_size: font_size || 200
			})
		end

		def perform
			tpl_dir = File.absolute_path @options.tpl_dir

			cd tpl_dir do
				hd = (File.exists? 'Screenshots' and File.directory? 'Screenshots')

				%w(Videos Screenlists Screenshots-Ex).each do |dir|
					raise ReleaserError, "Cannot find '#{tpl_dir}/#{dir}'!\n\tClean destination and run 'vrtk plato' to generate valid template." unless (File.exists? dir and File.directory? dir)
				end

				cd 'Videos' do

					p Dir.pwd

					Dir['*.mp4'].each do |file|

						puts %Q[For '#{file}']

						absfile = File.absolute_path file

						basename = File.basename file, '.mp4'


						puts %q[Generating 'Screenshots-Ex' directory]
						VRTK::VideoClipper.new(
							input_file:  file,
							output_dir:  "#{tpl_dir}/Screenshots-Ex/#{basename}",
							clips_count: 16,
							font_size:   (@options.font_size / 3.0).to_i
						).perform

						if hd
							puts %q[Generating screenshots (HD release)]
							cd "#{tpl_dir}/Screenshots-Ex/#{basename}" do
								array = Dir['*.jpeg']
								_file  = File.absolute_path (array - [array.first, array.last]).sample

								cp_r _file, "#{tpl_dir}/Screenshots/#{basename}.jpeg"
							end
						end

						dir = Dir.mktmpdir ['VRTK.Releaser', basename]

						puts %q[Generating screenshots to be formed into screenlist]
						VRTK::VideoClipper.new(
							input_file:  file,
							output_dir:  dir,
							clips_count: 16,
							font_size:   @options.font_size
						).perform

						puts %q[Performing Metalyzis]
						VRTK::Metalyzer.new(
							input_file:  absfile,
							output_file: "#{dir}/sc000001.jpeg",
							format:      'image'
						).perform

						puts %q[Generating screenlists]
						cd dir do
							VRTK::Collager.new(
								input_files: Dir['*.jpeg'],
								output_file: File.absolute_path("#{tpl_dir}/Screenlists/#{basename}.jpeg"),
								file_limit:  16
							).perform
						end

						puts %q[Cleaning up]
						rm_rf dir
					end
				end
			end
		end

		private
	end


end