require 'bundler'

require_relative '../../vrtk'

Bundler.require :utils

module VRTK::Utils
	def self.to_wpath(upath)
		"\"#{upath.gsub('/', '\\')}\""
	end

	def self.to_upath(wpath)
		"#{wpath.gsub('\\', '/')}"
	end

	def self.get_binpath
		ENV['PATH'].split(';').map { |v| v }
	end

	def self.to_wildcard(str)
		str
			.gsub('%', '*')
			.gsub('#', '?')
			.gsub('\\', '/')
	end
end