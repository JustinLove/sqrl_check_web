# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqrl/check/web/version'

Gem::Specification.new do |spec|
  spec.name          = "sqrl_check_web"
  spec.version       = SQRL::Check::Web::VERSION
  spec.authors       = ["Justin Love"]
  spec.email         = ["git@JustinLove.name"]

  spec.summary       = %q{Web interface to SQRL::Check SQRL test suite}
  spec.description   = %q{Web interface to SQRL::Check SQRL test suite}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sqrl_check"
  spec.add_runtime_dependency "sinatra", "~> 1.4"
  spec.add_runtime_dependency "thin", "~> 1.7"
  spec.add_runtime_dependency "sidekiq", "~> 4.2"
  spec.add_runtime_dependency "redis", "~> 3.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-process"
  spec.add_development_dependency "foreman"
end
