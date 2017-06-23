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
  spec.description   = 'Twitter word clouds. Analyse the frequency of word occurrences for a user or list of users. '\
    'Configurable - set the words to ignore, the range of dates to look at, and whether to include hashtags, '\
    '@-mentions, and URLs. Customize your Twitter configuration, too. Sensible defaults are provided for all options. '\
    'Look at the data in different ways. Easily convert and/or export to CSV and JSON. Change configuration options '\
    'on the fly and re-audit with ease.'

  spec.homepage      = 'https://github.com/msimonborg/twords'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z lib LICENSE.txt README.md twords.gemspec`.split("\0")

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'twitter', '~> 6.1.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
