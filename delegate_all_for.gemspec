# -*- encoding: utf-8 -*-
require File.expand_path('../lib/delegate_all_for/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Rust"]
  gem.email         = ["jason@lessonplanet.com"]
  gem.description   = %q{Easy delegation of all columns of an ActiveRecord association}
  gem.summary       = %q{Easy delegation of all columns of an ActiveRecord association}
  gem.homepage      = "https://github.com/LessonPlanet/delegate_all_for"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "delegate_all_for"
  gem.require_paths = ["lib"]
  gem.version       = DelegateAllFor::VERSION
  gem.add_dependency 'activerecord', '~> 3.2.3'
  gem.add_development_dependency 'rake', '~> 0.9.2.2'
  gem.add_development_dependency 'rspec', '~> 2.9.0'
  gem.add_development_dependency 'sqlite3', '~> 1.3.6'
end
