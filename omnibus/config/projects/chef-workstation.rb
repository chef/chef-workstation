#
# Copyright 2018 Chef Software, Inc.
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

name          "chef-workstation"
friendly_name "Chef Workstation"
maintainer    "Chef Software, Inc. <maintainers@chef.io>"
homepage      "https://chef.sh"

license "Chef EULA"
license_file "CHEF-EULA.md"

conflict "chefdk"

# Defaults to C:/chef-workstation on Windows
# and /opt/chef-workstation on all other platforms
# We'll force "c:/opscode/chef-workstation" - otherwise
# extracting version info after creating the package
# fails because it can't find c:/opscode/chef-workstation/version-manifest.txt
# when the install dir is configured to c:/chef-workstation.
if windows?
  install_dir "#{default_root}/opscode/#{name}"
else
  install_dir "#{default_root}/#{name}"
end

build_version Omnibus::BuildVersion.semver
build_iteration 1

# One problem with the ChefDK today is that it includes a shit load of gem
# dependencies.  We resolve all those dependencies in 1 location today - in the
# ChefDK repo (with its `Gemfile.lock`).

# We eventually want to fix that problem as part of implementing the Chef
# Workstation RFC (https://github.com/chef/chef-rfc/pull/308). But until we do
# we need to pull `chef-apply` in as a gem dependency of the ChefDK.

# In order to prevent unecessary cache expiration,
# package and package version overrides, build_version
# and build_iteration are kept in <project-root>/omnibus_overrides.rb
overrides_path = File.expand_path("../../../../omnibus_overrides.rb", __FILE__)
instance_eval(IO.read(overrides_path), overrides_path)

dependency "preparation"

if windows?
  dependency "git-windows"
else
  dependency "git-custom-bindir"
end

# For the Delivery build nodes
dependency "delivery-cli"
# This is a build-time dependency, so we won't leave it behind:
dependency "rust-uninstall"

# This internal component (source in components/gems)
# builds all gems that we ship with Workstation.
# No gems get shipped that are not declared in components/gems/Gemfile
dependency "gems"

dependency "chef-dk-gem-versions"

dependency "gem-permissions"
dependency "rubygems-customization"
dependency "shebang-cleanup"

if windows?
  dependency "chef-dk-env-customization"
  dependency "chef-dk-powershell-scripts"
end

dependency "version-manifest"
dependency "openssl-customization"

dependency "stunnel" if fips_mode?

# This *has* to be last, as it mutates the build environment and causes all
# compilations that use ./configure et all (the msys env) to break
if windows?
  dependency "ruby-windows-devkit"
  dependency "ruby-windows-devkit-bash"
  dependency "ruby-windows-system-libraries"
end

dependency "nodejs-binary"
dependency "chef-workstation-app"
dependency "uninstall-scripts"
dependency "ruby-cleanup"

exclude "**/.git"
exclude "**/bundler/git"

package :rpm do
  signing_passphrase ENV["OMNIBUS_RPM_SIGNING_PASSPHRASE"]
  compression_level 1
  compression_type :xz
end

package :deb do
  compression_level 1
  compression_type :xz
end

package :pkg do
  identifier "com.getchef.pkg.chef-workstation"
  signing_identity "Developer ID Installer: Chef Software, Inc. (EU3VF8YLX2)"
end

package :msi do
  fast_msi true
  upgrade_code "9870C512-DF2C-43D9-8C28-7ACD60ABBE27"
  wix_light_extension "WixUtilExtension"
  signing_identity "AF21BA8C9E50AE20DA9907B6E2D4B0CC3306CA03", machine_store: true
end

# We don't support appx builds, and they eat a lot of time.
package :appx do
  skip_packager true
end

compress :dmg
