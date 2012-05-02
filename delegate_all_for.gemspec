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
end
