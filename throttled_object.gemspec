# -*- encoding: utf-8 -*-
require File.expand_path('../lib/throttled_object/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Darcy Laycock"]
  gem.email         = ["sutto@sutto.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
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
