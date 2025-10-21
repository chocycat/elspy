# frozen_string_literal: true

require_relative 'lib/elspy/version'

Gem::Specification.new do |spec|
  spec.name = 'elspy'
  spec.version = Elspy::VERSION
  spec.authors = ['chocycat']
  spec.email = ['chocycat@catboy.to']

  spec.summary = 'Manage language servers and dev tools in one place'
  spec.description = 'A small recipe-based tool for managing language servers, formatters, and potentially other dev tools in one place'
  spec.homepage = 'https://github.com/chocycat/elspy'
  spec.license = 'AGPL-3.0-or-later'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{bin,lib,recipes}/**/*') + %w[README.md LICENSE elspy.gemspec]
  spec.bindir = 'bin'
  spec.executables = ['elspy']
  spec.require_paths = ['lib']
end
