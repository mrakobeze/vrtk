require_relative 'torrent_generator'
require_relative '../../vrtk'

require 'ostruct'

module VRTK
	class Torero

		include Torera

		def initialize(
			input_files: [],
			input_dirs: [],
			output_file: nil,
			root: nil
		)
			tgen = TorrentGenerator.new

			tgen.add_files (input_files || [])
			(input_dirs || []).each do |dir|
				tgen.add_folder dir
			end

			tgen.root = root || ''

			@options = OpenStruct.new ({
				generator:   tgen,
				output_file: output_file || 'out.torrent',
				root:        root
			})
		end

		def perform
			data = @options.generator.generate
			IO.binwrite @options.output_file, data
		end
	end
end
