# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twords/version'

Gem::Specification.new do |spec|
  spec.name          = 'twords'
  spec.version       = Twords::VERSION
  spec.authors       = ['M. Simon Borg']
  spec.email         = ['msimonborg@gmail.com']

  spec.summary       = 'Twitter word clouds'
  spec.description   = 'Twitter word clouds'
  spec.homepage      = 'https://github.com/msimonborg/twords'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z lib LICENSE.txt README.md twords.gemspec`.split("\0")

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'twitter', '~> 6.1.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
