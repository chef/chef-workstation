
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chef-workstation/version"

Gem::Specification.new do |spec|
  spec.name          = "chef-workstation"
  spec.version       = ChefWorkstation::VERSION
  spec.authors       = ["Marc A. Paradise"]
  spec.email         = ["marc.paradise@gmail.com"]

  spec.summary       = "The essential tool for the Chef ecosystem."
  spec.description   = "Manage individual nodes or the complete Chef ecosystem."
  spec.homepage      = "https://github.com/chef/chef-workstation/components/chef"
  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = %w{Rakefile LICENSE.txt README.md} +
    Dir.glob("Gemfile*") + # Includes Gemfile and locks
    Dir.glob("*.gemspec") +
    Dir.glob("{lib,spec,bin,vendor}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-config"
  spec.add_dependency "awesome_print"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "chefstyle"
end
