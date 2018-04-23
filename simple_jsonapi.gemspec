lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'simple_jsonapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_jsonapi'
  spec.version       = SimpleJsonapi::VERSION
  spec.license       = "MIT"
  spec.authors       = ['PatientsLikeMe']
  spec.email         = ['engineers@patientslikeme.com']
  spec.homepage      = 'https://www.patientslikeme.com'

  spec.summary       = 'A library for building JSONAPI documents in Ruby.'
  spec.description   = 'A library for building JSONAPI documents in Ruby.'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 5.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'mocha'
end
