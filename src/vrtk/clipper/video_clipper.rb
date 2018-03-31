require_relative 'ffmpeg'
require_relative 'font_finder'
require_relative '../utils/utils'
require_relative 'clipper_error'

require 'ostruct'
require 'logger'

STDNUL = (File.open(File::NULL, 'w'))

module VRTK

	class VideoClipper

		include VRTK::Clipper
		include VRTK::Utils

		CMD_DURATION = "%{ffprobe} -show_format -i \"%{input_file}\" -v 0 | sed -n \"s/duration=//p\""
		CMD_CLIPS    = "%{ffmpeg} -v 0 -i \"%{input_file}\" -vframes %{count} -vf \"drawtext=fontfile='%{font_file}': timecode='0\\:0\\:0\\:0': timecode_rate=60: x=100: y=50: fontsize=%{font_size}: fontcolor=white@1: borderw=3: bordercolor=black@1\" -r %{freq} -f image2 \"%{output_dir}/sc%%06d.jpeg\""

		def initialize(
			input_file:,
			clips_count: 16,
			output_dir: nil,
			font_size: 200,
			logger: nil
		)
			@options = OpenStruct.new ({
				input:  mk_input(input_file),
				count:  clips_count || 16,
				font_size: font_size || 200,
				output: output_dir || "#{input_file}.dir",
				logger: logger || Logger.new(STDNUL)
			})

			@ffmpeg = FFMpeg.resolve
		end

		def get_duration
			cmd = CMD_DURATION % {
				ffprobe:    @ffmpeg.ffprobe,
				input_file: @options.input
			}

			@options.logger.info "shell.exec #{cmd}"

			`#{cmd}`.to_f
		end

		def perform
			FileUtils.mkdir_p @options.output

			cmd = (CMD_CLIPS % {
				ffmpeg:     @ffmpeg.ffmpeg,
				input_file: @options.input,
				freq:       get_clip_frequency(get_duration, @options.count),
				output_dir: @options.output,
				count:      @options.count,
				font_file:  FontFinder.find_font('consola'),
				font_size: @options.font_size
			})

			@options.logger.info "shell.exec #{cmd}"

			print `#{cmd}`

			OpenStruct.new ({
				list: Dir["#{@options.output}/sc*.jpeg"],
				mask: "#{@options.output}/sc*.jpeg"
			})
		end

		private

		def get_clip_frequency(duration, sc_count)
			sc_count.to_f / duration
		end

		def mk_input(input_f)
			input_f = File.absolute_path input_f
			raise ClipperError, "Cannot locate file '#{input_f}'" unless File.exists? input_f
			input_f
		end

	end

end