# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enum_args/version'

Gem::Specification.new do |spec|
  spec.name          = "enum_args"
  spec.version       = EnumArgs::VERSION
  spec.authors       = ["Alejandro Martinez Ruiz"]
  spec.email         = ["alex@flawedcode.org"]

  spec.summary       = %q{Use Enumerable methods with parameters for your enumerator.}
  spec.description   = %q{This gem lets you use Enumerable methods with parameters for your custom enumerator.}
  spec.homepage      = "http://github.com/unleashed/enum_args"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
