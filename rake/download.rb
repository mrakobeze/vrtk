require 'bundler'

Bundler.require :dev

def download(url, target_file)
	data = ''
	url  = URI.parse url

	Net::HTTP.start(url.host, url.port, use_ssl: true).request_get(url.path) do |response|
		length = response['Content-Length'].to_i
		done   = 0

		bar = ProgressBar.create(
			format:        "#{target_file} [%B] %P% %e %r KiB/s (%c/%C bytes)",
			progress_mark: '=',
			total:         length,
			rate_scale:    lambda do |rate|
				rate / 1024
			end
		)

		response.read_body do |fragment|
			data << fragment
			done = done + fragment.length

			bar.progress = done
		end

	end

	IO.binwrite target_file, data
end

