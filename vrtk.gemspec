lib = File.expand_path('../src', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vrtk/version'

Gem::Specification.new do |spec|
	spec.name    = 'vrtk'
	spec.version = VRTK::VERSION
	spec.authors = ['MRAKOBEZE']
	spec.email   = 'mrakobeze@pm.me'

	spec.summary  = %q{Video Releasers TOolKit is a bunch of tools needed to make screenshots, previews and more form videos.}
	spec.homepage = 'https://github.com/mrakobeze/vrtk'
	spec.license  = 'MIT'

	if spec.respond_to?(:metadata)
		spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
	else
		raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
	end

	spec.files = `git ls-files`.split(/[\r\n]+/).map(&:strip)

	spec.bindir        = 'bin'
	spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
	spec.require_paths = ['src']

end
