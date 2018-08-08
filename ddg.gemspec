# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ddg/version'

Gem::Specification.new do |spec|
  spec.name = 'ddg'
  spec.version = DDG::VERSION
  spec.authors = ['Brandon Powers']
  spec.email = ['brandonkpowers@gmail.com']

  spec.summary = 'DDG is a tool for building and ' \
                 'manipulating database dependency graphs (DDG).'
  spec.description = ''
  spec.homepage = 'https://github.com/brandon-powers/ddg'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split("\n")
  spec.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.bindir = 'bin'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'rgl'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'mysql2'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'byebug'
end
