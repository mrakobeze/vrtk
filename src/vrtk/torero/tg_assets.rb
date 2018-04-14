require_relative '../utils/utils'
require_relative '../../vrtk'

module VRTK::Torera
	module Assets

		def clean_path(path)
			(
			if ENV['OS'].downcase.start_with? 'windows'
				clp_w32 path
			else
				clp_nix path
			end)
				.gsub(/[:]/, '$$')
		end

		private

		def clp_w32(path)
			VRTK::Utils.clean_path(path).downcase
		end

		def clp_nix(path)
			VRTK::Utils.clean_path(path)
		end
	end
end