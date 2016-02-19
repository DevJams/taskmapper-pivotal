# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require './lib/provider/version'

Gem::Specification.new do |spec|
  spec.name          = "taskmapper-pivotal"
  spec.version       = TaskMapper::Provider::Pivotal::VERSION
  spec.authors       = ["www.hybridgroup.com"]
  spec.email         = ["info@hybridgroup.com"]
  spec.description   = %q{A TaskMapper provider for interfacing with Pivotal Tracker.}
  spec.summary       = %q{A TaskMapper provider for interfacing with Pivotal Tracker.}
  spec.homepage      = "http://ticketrb.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
#   spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

#   spec.add_dependency "taskmapper", "~> 1.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
