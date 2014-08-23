# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_publisher/version'

Gem::Specification.new do |spec|
  spec.name          = "active_publisher"
  spec.version       = ActivePublisher::VERSION
  spec.authors       = ["Omar Abdel-Wahab"]
  spec.email         = ["owahab@gmail.com"]
  spec.summary       = %q{ActivePublisher brings PubSub to Rails models and controllers.}
  spec.description   = %q{ActivePublisher brings PubSub to Rails models and controllers.}
  spec.homepage      = "http://github.com/owahab/active_publisher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.0.0" #TODO: fix this
  spec.add_dependency "redis"
  spec.add_dependency "redis-namespace"
  # spec.add_dependency "activesupport", ">= 4.0.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_girl_rails"
  spec.add_development_dependency "rubygems-tasks"
end
