require_relative '../../vrtk'
require_relative '../utils/utils'

require 'ostruct'
require 'logger'

module VRTK::Clipper

	class FFMpegError < VRTK::VRTKError;
	end

	class FFMpeg
		include VRTK

		PREDEF_PATHS = %W(#{Dir.pwd}/bin #{Dir.pwd}/ffmpeg #{Dir.pwd}/ffmpeg/bin)

		def self.resolve
			if ENV['OS'].downcase.start_with? 'windows'
				resolve_ffmpeg_windows
			else
				resolve_ffmpeg_unknown
			end
		end

		def self.resolve_ffmpeg_unknown
			raise FFMpegError, "Can't resolve FFMPEG correctly"
		end

		private

		# noinspection RubyScope
		def self.resolve_ffmpeg_windows
			search = (Utils.get_binpath + PREDEF_PATHS)
				         .map { |v| File.absolute_path Utils.to_upath(v) }

			search.each do |v|
				search << "#{v}/ffmpeg"
				search << "#{v}/bin"
				search << "#{v}/ffmpeg/bin"
			end

			mpeg  = nil
			probe = nil

			search.each do |path|
				mp    = "#{path}/ffmpeg.exe" unless mpeg
				pb    = "#{path}/ffprobe.exe" unless probe

				mpeg  = mp if mp and File.exists? mp
				probe = pb if pb and File.exists? pb

				break if mpeg and probe
			end

			raise FFMpegError, "Can't resolve ffmpeg.exe" unless mpeg
			raise FFMpegError, "Can't resolve ffprobe.exe" unless probe

			OpenStruct.new ({
				ffmpeg:  Utils.to_wpath(mpeg),
				ffprobe: Utils.to_wpath(probe)
			})
		end
	end

end