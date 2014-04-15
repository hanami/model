# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/model/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-model'
  spec.version       = Lotus::Model::VERSION
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.summary       = %q{Model layer for Lotus}
  spec.description   = %q{Model framework with repositories, entities and query objects}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lotus-utils', '~> 0.1'
  spec.add_runtime_dependency 'sequel',      '~> 4.9'

  spec.add_development_dependency 'bundler',  '~> 1.5'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake',     '~> 10'
end
