require_relative '../utils/ffmpeg'
require_relative '../utils/font_finder'
require_relative '../utils/utils'
require_relative 'clipper_error'

require 'ostruct'
require 'ruby-progressbar'
require 'logger'

STDNUL = (File.open(File::NULL, 'w'))

module VRTK

	class VideoClipper

		include VRTK::Clipper
		include VRTK::Utils

		CMD_DURATION = "%{ffprobe} -show_format -i \"%{input_file}\" -v 0"
		CMD_ONE_CLIP = "%{ffmpeg} -v 0 -ss %{timestamp} -i \"%{input_file}\" -vf \"drawtext=fontfile='%{font_file}': text='%{ts_escaped}': x=10: y=10: fontsize=%{font_size}: fontcolor=white@1: borderw=3: bordercolor=black@1\"  -q:v 1 -vframes 1 -f image2 \"%{output_dir}/sc%<number>06d.jpeg\""

		def initialize(
			input_file:,
			clips_count: 16,
			output_dir: nil,
			font_size: 200,
			logger: nil
		)
			@options = OpenStruct.new ({
				input:     mk_input(input_file),
				count:     clips_count || 16,
				font_size: font_size || (200),
				output:    output_dir || "#{input_file}.dir",
				logger:    logger || Logger.new(STDNUL)
			})

			@ffmpeg = FFMpeg.resolve
		end

		def get_duration
			cmd = CMD_DURATION % {
				ffprobe:    @ffmpeg.ffprobe,
				input_file: @options.input
			}

			# @options.logger.info "shell.exec #{cmd}"

			duration = `#{cmd}`
				           .split("\n")
				           .grep(/^duration/)[0]
				           .split('=')

			raise ClipperError, 'Cannot get duration' unless duration.size == 2

			duration[1].to_f
		end

		def perform

			@options.logger.warn %Q[Please note that all '#{@options.output}' will be removed!]

			FileUtils.rm_rf @options.output
			FileUtils.mkdir_p @options.output

			pb = ProgressBar.create(
				title:  "#{File.basename(@options.input)}",
				total:  @options.count,
				format: '%t [%b>%i] %c/%C'
			)

			stamps = get_clip_stamps(get_duration, @options.count)

			pb.progress = 0

			files = []

			stamps.each_with_index do |stamp, index|
				cmd = (CMD_ONE_CLIP % {
					ffmpeg:     @ffmpeg.ffmpeg,
					input_file: @options.input,
					timestamp:  stamp,
					ts_escaped: stamp.gsub(':', '\\:').gsub('.', '\\.'),
					number:     (index + 1),
					output_dir: @options.output,
					count:      @options.count,
					font_file:  FontFinder.find_font('consola'),
					font_size:  @options.font_size
				})

				`#{cmd}`

				fname = '%s/sc%06d.jpeg' % [@options.output, index + 1]

				files << File.absolute_path(fname)

				pb.progress += 1
			end

			OpenStruct.new ({
				list: files
			})
		end

		private

		def get_clip_stamps(duration, count, actual_count: nil)
			actual_count = actual_count || count

			seg_duration = duration / count

			durations = []

			current = 0

			loop do
				break if current > duration
				durations << ts_format(current)
				current += seg_duration
			end

			durations.pop

			durations = get_clip_stamps(duration, count + 1, actual_count: actual_count) if durations.size < actual_count

			durations[0...count]
		end

		def ts_format(ts)

			sec = ts % 60
			ts  /= 60
			min = ts % 60
			ts  /= 60
			hr  = ts % 100

			('%02d:%02d:%02d' % [hr, min, sec])
		end

		def mk_input(input_f)
			input_f = File.absolute_path input_f
			raise ClipperError, "Cannot locate file '#{input_f}'" unless File.exists? input_f
			input_f
		end

	end

end