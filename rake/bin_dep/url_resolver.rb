require_relative 'base_resolver'

module BinDep
	class URLResolver < BaseResolver

		attr_accessor :url

		def self.create(url, dist_dir: 'dist/bindeps/', logger:)
			resolver = URLResolver.new(dist_dir: dist_dir, logger: logger)

			resolver.url = url
			uri          = URI(url % { depname: '' })

			logger.debug "resolving bindeps from #{uri.scheme}://#{uri.host}"

			resolver
		end

		def get_url(name)
			url % { depname: name }
		end
	end
end
