module Inno

	class InnoError < Exception;
	end

	class IssGenerator
		def initialize(template)
			@file = File.absolute_path template
			raise InnoError, "Template file '#{file}' does not exist" unless File.exists? @file
		end

		def generate(to, bind:)
			tpl = IO.read(@file).strip % bind

			IO.write to, tpl
		end

		def build(file)
			system %Q[iscc #{file}]
		end

		private
		def beautify_codename(codename)
			codename
				.split('-')
				.map(&:capitalize)
				.join('')
		end
	end
end