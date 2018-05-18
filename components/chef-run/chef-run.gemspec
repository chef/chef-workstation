#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chef-run/version"

Gem::Specification.new do |spec|
  spec.name          = "chef-run"
  spec.version       = ChefRun::VERSION
  spec.authors       = ["Chef Software, Inc"]
  spec.email         = ["beta@chef.io"]

  spec.summary       = "The ad-hoc execution tool for the Chef ecosystem."
  spec.description   = "Ad-hoc management of individual nodes and devices."
  spec.homepage      = "https://github.com/chef/chef-workstation/components/chef-run"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = ">= 2.5.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = %w{Rakefile LICENSE README.md} +
    Dir.glob("Gemfile*") + # Includes Gemfile and locks
    Dir.glob("*.gemspec") +
    Dir.glob("{lib,bin,vendor,i18n}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-cli"    # Provides argument handling DSL for CLI applications
  spec.add_dependency "mixlib-config" # shared chef configuration library that
                                      # simplifies managing a configuration file
  spec.add_dependency "mixlib-log"    # Basis for our traditional logger
  spec.add_dependency "mixlib-install" # URL resolver + install tool for chef products
  spec.add_dependency "r18n-desktop" # easy path to message text management via
                                     # localization gem...
  spec.add_dependency "toml-rb" # This isn't ideal because mixlib-config uses 'tomlrb'
                                # but that library does not support a dumper
  spec.add_dependency "train" # remote connection management over ssh, winrm
  spec.add_dependency "pastel" # A color library
  spec.add_dependency "tty-spinner" # Pretty output for status updates in the CLI
  spec.add_dependency "chef", ">= 14.0" # Needed to load cookbooks
  spec.add_dependency "chef-dk", ">= 3.0"
  spec.add_dependency "chef-telemetry"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "chefstyle"
end
