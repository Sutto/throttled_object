# -*- encoding: utf-8 -*-
require File.expand_path('../lib/throttled_object/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Darcy Laycock"]
  gem.email         = ["darcy@filtersquad.com"]
  gem.description   = %q{Distributed Object Locks built on Redis.}
  gem.summary       = %q{Distributed Object Locks built on Redis.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "throttled_object"
  gem.require_paths = ["lib"]
  gem.version       = ThrottledObject::VERSION

  gem.add_dependency 'redis', '~> 3.0'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'rspec', '~> 2.0'
  gem.add_development_dependency 'rake'

end
