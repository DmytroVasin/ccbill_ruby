# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ccbill_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "ccbill_ruby"
  spec.version       = CCBill::VERSION
  spec.authors       = ["Dmytro Vasin"]
  spec.email         = ["dmytro.vasin@gmail.com"]

  spec.summary       = "Unofficial CCBill SDK for Ruby"
  spec.description   = "Provides interfaces to interact with CCBill services."
  spec.homepage      = "https://github.com/DmytroVasin/ccbill_ruby/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.6.0"
  spec.add_development_dependency "pry"
end
