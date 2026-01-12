#
# Copyright:: Copyright (c) 2018-2025 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
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

name "chef-workstation-app"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"

# These three lines are updated automatically by Expeditor
default_version "0.2.191"
source sha1: "626695935f339114adfdfe29ac4b68f4088096f7" if windows?
source sha1: "a13ba6239fbc839daeb5a6800bac87bcb74c257f" if linux?

# update the version list and shasum based when default version is updated
if macos?
  if arm?
    platform_name = "darwin-arm64"
    version("0.2.191") do
      source sha256: "430c42999c07c41ab0eb27bcb40b7925b5311987c1d7cad352c4516a57540f24"
    end
  else
    platform_name = "darwin-x64"
    version("0.2.191") do
      source sha256: "135ab6c1ac447399a918094ba50d720f842cf0515714709967fe4ce56059c477"
    end
  end
elsif windows?
  platform_name = "win32-x64"
  version("0.2.191") do
    source sha256: "09e63b50167f00d0ceb1e14cba4a3621b2d7109141fd1b338942e5f33a95c7b7"
  end
else
  platform_name = "linux-x64"
  version("0.2.191") do
    source sha256: "3690120a99e11e1ff64b9a9d74a4fdd51fcb4dae1987bec92f006903b1a24de4"
  end
end

source_url = "https://packages.chef.io/files/unstable/chef-workstation-app/#{version}/chef-workstation-app-#{version}-#{platform_name}.zip"

internal_source url: "https://packages.chef.io/files/unstable/chef-workstation-app/#{version}/chef-workstation-app-#{version}-#{platform_name}.zip"

app_install_path = "#{install_dir}/components/chef-workstation-app"

# These electron dependencies are pulled in/created
# by this build. They may have dependencies that aren't met
# on the install target - in which case the tray application
# will not be runnable.  That does not affect the rest of
# the chef-workstation installation, so we will whitelist the
# dependencies to allow it to continue in any case.
if linux?
  whitelist_file(%r{components/chef-workstation-app/libGLESv2\.so})
  whitelist_file(%r{components/chef-workstation-app/chef-workstation-app})
end

# The macOS zip file is weird. We can't really expand it because it expands directly into the .app.
# To get around this we download it as a zip and unzip it as part of postinst.
if macos?
  build do
    mkdir app_install_path
    command "curl -Lsf -o #{app_install_path}/chef-workstation-app-mac.zip #{source_url}"
  end
else
  source url: source_url

  build do
    mkdir app_install_path
    copy "#{project_dir}/*", app_install_path
  end
end
