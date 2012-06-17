# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oqgraph_rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Stuart Coyle"]
  gem.email         = ["stuart.coyle@gmail.com"]
  gem.description   = %q{Enables the use of OpenQuery\'s OQGraph engine with active record. OQGraph is a graph database engine for MySQL.'}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "oqgraph_rails"
  gem.require_paths = ["lib"]
  gem.version       = OqgraphRails::VERSION
  gem.add_runtime_dependency 'mysql2'
  gem.add_runtime_dependency 'activerecord'
end
