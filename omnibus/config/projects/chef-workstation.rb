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

license "Apache-2.0"
license_file "../LICENSE"

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

# This means the promotion process for getting new Chef Apply changes out is:
# 1. Merge the Chef Apply PR which causes expeditor to build a new gem
# 2. Update the dependencies in the ChefDK with a PR
# 3. Perform a new build of Chef Workstation. Because it pulls in ChefDK from
# `master` it will get the latest ChefDK and transitively the latest update
# to Chef Apply.

# I've automated steps 1 and 3. This means that the _new_ process for promoting
# Chef Apply changes is:
# 1. Update the dependencies in the ChefDK with a PR
# 2. After Chef Workstation gets a new build triggered and completed, promote Chef Workstation as normal

# I realize this is not ideal but I think its the best way forward today. We
# could try and do something sneaky/cute where we pull Chef Apply into
# Chef Workstation as a separate dependency but that exposes the risk that we
# break dependency resolution for the ChefDK (and transitively Chef Workstation)

override :"chef-dk",      version: "master"

# DK's overrides; god have mercy on my soul
# This comes from DK's ./omnibus_overrides.rb
# If this stays, may need to duplicate that file and the rake
# tasks for updating dependencies
override :rubygems, version: "2.7.6"
override :bundler, version: "1.16.1"
override "libffi", version: "3.2.1"
override "libiconv", version: "1.15"
override "liblzma", version: "5.2.3"
override "libtool", version: "2.4.2"
override "libxml2", version: "2.9.8"
override "libxslt", version: "1.1.30"
override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "5.9"
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "2.5.1"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"
override "libzmq", version: "4.0.7"
override "openssl", version: "1.0.2p"
override "nodejs", version: "10.9.0"
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

dependency "chef-dk"

dependency "gem-permissions"
dependency "rubygems-customization"

if windows?
  dependency "chef-dk-env-customization"
  dependency "chef-dk-powershell-scripts"
end

dependency "version-manifest"
dependency "clean-static-libs"
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

exclude "**/.git"
exclude "**/bundler/git"

package :rpm do
  signing_passphrase ENV["OMNIBUS_RPM_SIGNING_PASSPHRASE"]
end

package :pkg do
  identifier "com.getchef.pkg.chef-workstation"
  signing_identity "Developer ID Installer: Chef Software, Inc. (EU3VF8YLX2)"
end

package :msi do
  fast_msi true
  upgrade_code '9870C512-DF2C-43D9-8C28-7ACD60ABBE27'
  wix_light_extension 'WixUtilExtension'
  signing_identity 'E05FF095D07F233B78EB322132BFF0F035E11B5B', machine_store: true
end

compress :dmg
