# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reloadlive/version'

Gem::Specification.new do |spec|
  spec.name          = "reloadlive"
  spec.version       = Reloadlive::VERSION
  spec.authors       = ["Alberto Miorin"]
  spec.email         = ["reloadlive@ululi.it"]
  spec.description   = %q{Reloadlive is a command line tool to easily preview your github-markup files}
  spec.summary       = %q{Reloadlive is a command line tool to easily preview your github-markup files}
  spec.homepage      = "https://github.com/amiorin/reloadlive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "thin"
  spec.add_dependency "faye"
  spec.add_dependency "listen"
  spec.add_dependency "github-markup"
  spec.add_dependency "github-markdown"
  spec.add_dependency "pygments.rb", "~> 0.4.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "guard-rspec"
end
