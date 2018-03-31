require 'bundler'

require_relative '../../vrtk'
require_relative '../utils/utils'

Bundler.require :collager

module VRTK

	module Collage
		class CollagerError < VRTK::VRTKError;
		end
	end

	class Collager

		def initialize(
			input_files:,
			output_file: nil,
			tile_ratio: [16, 9],
			file_limit: nil,
			collage_width: 1200
		)
			file_limit = [file_limit || input_files.size, input_files.size].min

			@options = OpenStruct.new({
				                          files:  input_files[0...file_limit],
				                          output: output_file || "#{Dir.pwd}/out.jpeg",
				                          dim:    tile_ratio|| [16, 9],
				                          width:  collage_width || 1200
			                          })

			@tmp_dir = Dir.mktmpdir %w(VRTK.Collager rb)
		end

		def perform

			@options.files.map! do |file|
				File.absolute_path file
			end

			layout = generate_layout @options.files.size, @options.dim, @options.width

			files = resize_each @options.files, *layout.tile_size

			montage = MiniMagick::Tool::Montage.new

			files.each { |image| montage << image }

			montage << '-mode'
			montage << 'Concatenate'
			montage << '-background'
			montage << 'none'
			montage << '-geometry'
			montage << "#{layout.tile_size.join('x')}+0+0"
			montage << '-tile'
			montage << layout.layout
			montage << (@options.output)

			montage.call

			finalize

			@options.output
		end

		private

		# noinspection RubyResolve
		def resize_to_fill(width, height, img, gravity='Center')
			cols, rows = img[:dimensions]
			img.combine_options do |cmd|
				if width != cols || height != rows
					scale_x = width/cols.to_f
					scale_y = height/rows.to_f
					if scale_x >= scale_y
						cols = (scale_x * (cols + 0.5)).round
						rows = (scale_x * (rows + 0.5)).round
						cmd.resize "#{cols}"
					else
						cols = (scale_y * (cols + 0.5)).round
						rows = (scale_y * (rows + 0.5)).round
						cmd.resize "x#{rows}"
					end
				end

				cmd.gravity gravity
				cmd.background 'rgba(255,255,255,0.0)'
				cmd.extent "#{width}x#{height}" if cols != width || rows != height
			end
		end

		def finalize
			FileUtils.rm_rf @tmp_dir
		end

		def generate_layout(files_count, orig_size, wanted_width)
			ow, oh = orig_size

			ch = Math.sqrt(files_count).to_i
			cw = (files_count.to_f / ch.to_f).ceil.to_i

			opw = cw * ow
			oph = ch * oh

			pw = wanted_width
			ph = ((pw.to_f / opw.to_f) * oph).to_i

			mw, mh = [pw / cw, ph / ch]

			OpenStruct.new({
				               layout:    [cw, ch].join('x'),
				               full_size: [pw, ph],
				               tile_size: [mw, mh]
			               })
		end

		def resize_each(files, width, height)
			FileUtils.rm_rf @tmp_dir
			FileUtils.mkdir @tmp_dir

			n_files = []

			files.each do |f|
				image = MiniMagick::Image.open(f)
				resize_to_fill(width, height, image)
				image.format "jpg"

				xf = Digest::MD5.hexdigest f
				xf = "#{@tmp_dir}/#{xf}.jpg"
				image.write xf
				n_files << xf
			end

			n_files
		end

	end
end