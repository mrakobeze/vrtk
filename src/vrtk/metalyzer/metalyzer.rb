require_relative '../utils/utils'
require_relative '../utils/ffmpeg'
require_relative '../utils/font_finder'
require_relative '../utils/resource_finder'
require_relative 'metalyzer_error'

require 'json'
require 'ostruct'
require 'fileutils'
require 'tmpdir'
require 'logger'

class String
	def fitline(nfit = 35)
		lines = []
		s = self.split ''
		st = 0

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

	class Metalyzer

		CMD_GET_FMT_DATA    = '%{ffprobe} -v 0 -show_format "%{input_file}"'
		CMD_GET_STREAM_DATA = '%{ffprobe} -v 0 -show_streams "%{input_file}"'
		CMD_TEXT2IMG        = %Q[%{ffmpeg} -v 0 -i "%{bg_image}" -vf "drawtext=fontfile='%{font_file}': textfile='%{text_file}': x=50: y=240: fontsize=60: fontcolor=white@1: borderw=3: bordercolor=black@1" -f image2 "%{output_file}"]

		include VRTK::Metalyze
		include VRTK::Utils

		def initialize(
			input_file: nil,
			output_file: nil,
			format: nil
		)
			raise MetalyzerError 'no input file specified!' if input_file.nil?

			@options = OpenStruct.new ({
				input:      mk_input(input_file),
				output:     output_file || ((format || 'image') == 'image' ? 'meta.jpg' : 'meta.txt'),
				out_format: format || 'image'
			})

			@ffmpeg = FFMpeg.resolve
		end

		def perform
			cmd = CMD_GET_STREAM_DATA % {
				ffprobe:    @ffmpeg.ffprobe,
				input_file: @options.input
			}

			ffout = `#{cmd}`

			smeta = Metalyzer.ffout_parse ffout

			cmd = CMD_GET_FMT_DATA % {
				ffprobe:    @ffmpeg.ffprobe,
				input_file: @options.input
			}

			ffout = `#{cmd}`

			fmeta = Metalyzer.ffout_parse ffout

			# noinspection RubyArgCount,RubyStringKeysInHashInspection
			meta = ({
				'format' => fmeta,
				'stream' => smeta
			})


			text = []

			FileUtils.rm_rf @options.output

			text << (%Q[#{fp_rel(meta['format']['filename'])}]).to_s.fitline(35)
			text << (%Q[Duration: #{ts_format(meta['format']['duration'].to_f.to_i)}]).to_s.fitline(35)
			text << (%Q[Codec: #{(meta['stream']['codec_name'])}]).to_s.fitline(35)
			text << (%Q[Size: #{sz_format(meta['format']['size'].to_i)}]).to_s.fitline(35)
			text << (%Q[Dim: #{(meta['stream']['width'].to_i)}x#{(meta['stream']['height'].to_i)}]).to_s.fitline(35)

			tmpdir = Dir.mktmpdir('VRTK.Metalyzer')

			IO.write "#{tmpdir}/meta.txt", text.join("\n")

			case (@options.out_format)
				when 'text'
					FileUtils.cp_r "#{tmpdir}/meta.txt", @options.output
				when 'image'
					cmd = CMD_TEXT2IMG % {
						ffmpeg:      @ffmpeg.ffmpeg,
						text_file:   "#{tmpdir}/meta.txt".gsub(':', '\\:'),
						font_file:   FontFinder.find_font('consola'),
						output_file: @options.output,
						bg_image:    mkpath(ResourceFinder.find_resources('black_bg.jpg')[0])
					}


					`#{cmd}`
				else
					# do nothing
			end
		end

		private

		def fp_rel(fp)
			File.basename fp
		end

		def ts_format(ts)
			sec = ts % 60
			ts  /= 60
			min = ts % 60
			ts  /= 60
			hr  = ts % 100

			('%02d:%02d:%02d' % [hr, min, sec])
		end

		def sz_format(size)
			t_size = %w(b KiB MiB GiB TiB PiB EiB)
			t_pos  = 0

			size *= 100

			loop do
				break if size < 60000
				t_pos += 1
				size  /= 1024
			end

			"#{size.to_f / 100.0} #{t_size[t_pos]}"
		end

		def self.ffout_parse(ffout)
			lines = ffout.split(/[\r\n]+/).map(&:strip)

			hash = {}

			lines.each do |line|
				if (line =~ (/^\[(\/?)([\S^\[\]]+)\]/)).nil?
					name, value = line.split(/\s*=\s*/)
					hash[name]  = value if hash[name].nil?
				end
			end

			hash
		end

		def mk_input(input_f)
			input_f = File.absolute_path input_f
			raise ClipperError, "Cannot locate file '#{input_f}'" unless File.exists? input_f
			input_f
		end

		def mkpath(path)
			File.absolute_path(path)
		end
	end


end