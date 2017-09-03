# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ccbill_ruby/version'

Gem::Specification.new do |gem|
  gem.name          = "ccbill_ruby"
  gem.version       = CCBill::VERSION
  gem.authors       = ["Dmytro Vasin"]
  gem.email         = ["dmytro.vasin@gmail.com"]

  gem.summary       = "Unofficial CCBill SDK for Ruby"
  gem.description   = "Provides interfaces to interact with CCBill services."
  gem.homepage      = "https://github.com/DmytroVasin/ccbill_ruby/"
  gem.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if gem.respond_to?(:metadata)
  #   gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "thor", "~> 0.19.4"

  gem.add_development_dependency "bundler", "~> 1.14"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.6.0"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "json"
end
