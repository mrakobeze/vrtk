lib = File.expand_path('../src', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'vrtk/version'

Gem::Specification.new do |spec|
	spec.name    = 'vrtk'
	spec.version = VRTK::VERSION
	spec.authors = ['MRAKOBEZE']
	spec.email   = 'mrakobeze@pm.me'

	spec.summary = ''
	spec.homepage = 'https://github.com/mrakobeze/vrtk'
	spec.license  = 'MIT'

	spec.files = `git ls-files`.split(/[\r\n]+/).map(&:strip)

	spec.bindir        = 'bin'
	spec.executables   = ['vrtk']
	spec.require_paths = ['src']

	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'rake'
end
