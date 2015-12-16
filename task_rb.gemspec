# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'task/version'

Gem::Specification.new do |spec|
  spec.name          = "task_rb"
  spec.version       = Task::VERSION
  spec.authors       = ["Arron Norwell"]
  spec.email         = ["anorwell@datto.com"]

  spec.summary       = %q{Task provides a toolbox for generating, tracking and serializing tasks to be performed.}
  spec.homepage      = "http://datto.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"

  spec.add_dependency 'pyper_rb', '~> 1.0.0'
  spec.add_dependency 'cassava_rb'
  spec.add_dependency 'virtus'
  spec.add_dependency 'values'
  spec.add_dependency "activesupport"
end
