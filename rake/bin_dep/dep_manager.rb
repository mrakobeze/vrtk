require 'yaml'
require 'ostruct'

require_relative '../bin_dep/bin_dep'

module BinDep
	class DepManager
		def initialize(file: 'dist/bindeps/bindeps.yml')
			@file = file
		end

		def load
			YAML.load_file(@file)['bindeps']
		end
	end
end