require_relative '../utils/utils'
require_relative '../utils/ffmpeg'
require_relative '../utils/font_finder'
require_relative '../utils/resource_finder'
require_relative 'templator_error'

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

	class Templator

		TPL_DIRS = %w(Screenshots-Ex Screenlists Videos)

		CMD_GET_FMT_DATA    = '%{ffprobe} -v 0 -show_format "%{input_file}"'
		CMD_GET_STREAM_DATA = '%{ffprobe} -v 0 -show_streams "%{input_file}"'
		CMD_TEXT2IMG        = %Q[%{ffmpeg} -v 0 -i "%{bg_image}" -vf "drawtext=fontfile='%{font_file}': textfile='%{text_file}': x=50: y=240: fontsize=60: fontcolor=white@1: borderw=3: bordercolor=black@1" -f image2 "%{output_file}"]

		include VRTK::Template
		include VRTK::Utils
		include FileUtils

		def initialize(
			video_files: nil,
			output_dir: nil,
			hd: false,
			move_input: false
		)
			@options = OpenStruct.new ({
				hd:     (hd || false),
				move:   (move_input || false),
				output: output_dir || 'template',
				input:  (video_files || []).map { |v| File.absolute_path v }
			})

			@ffmpeg = FFMpeg.resolve
		end

		def perform
			out_dir = File.absolute_path @options.output

			rm_rf out_dir
			mkdir_p out_dir

			tdirs = TPL_DIRS

			tdirs << 'Screenshots' if @options.hd

			cd out_dir do
				tdirs.each { |dir| mkdir_p dir }

				cd 'Videos' do
					@options.input.each do |file|
						FileUtils.send (@options.move ? :mv : :cp_r), file, '.'
					end
				end
			end
		end

		private

		def fp_rel(fp)
		end

		def ts_format(ts)
		end

		def sz_format(size)
		end

		def self.ffout_parse(ffout)
		end

		def mk_input(input_f)
		end

		def mkpath(path)
		end
	end


end