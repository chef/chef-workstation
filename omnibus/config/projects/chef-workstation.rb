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
# if
if windows?
  install_dir "#{default_root}/opscode/#{name}"
else
  install_dir "#{default_root}/#{name}"
end


build_version Omnibus::BuildVersion.semver
build_iteration 1

override :bundler,        version: "1.16.1"
override :rubygems,       version: "2.6.13"
override :ruby,           version: "2.4.2"

dependency "preparation"
dependency "chef-workstation"
dependency "clean-static-libs"
dependency "version-manifest"

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
