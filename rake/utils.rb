require 'ruby-progressbar'
require 'net/http'
require 'tmpdir'
require 'fileutils'

require_relative 'beta/utils/zip'

module Utils
	include FileUtils

	def download(url, target:)
		data = ''
		url  = URI.parse url

		Net::HTTP.start(url.host, url.port, use_ssl: true).request_get(url.path) do |response|
			length = response['Content-Length'].to_i
			done   = 0

			bar = ProgressBar.create(
				title:      File.basename(target),
				format:     '%t [%b>%i] %P% %e %r KiB/s (%c/%C bytes)',
				total:      length,
				rate_scale: lambda do |rate|
					rate / 1024
				end
			)

			response.read_body do |fragment|
				data << fragment
				done = done + fragment.length

				bar.progress = done
			end
		end

		IO.binwrite target, data
	end

	def tmpfile(prefix: '', suffix: '')
		dir  = Dir.mktmpdir [prefix, suffix]
		file = "#{dir}/file.tmp"

		yield File.absolute_path(file)

		rm_rf dir
	end
end