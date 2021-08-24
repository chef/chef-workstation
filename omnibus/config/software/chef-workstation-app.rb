#
# Copyright:: Copyright Chef Software, Inc.
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
default_version "0.2.45"
source sha1: "377c2f9409a57f7db3577d0476a3c541e6e2ed54" if windows?
source sha1: "4261e9a501386313031ceafd8fa49aef013b8866" if linux?

platform_name = if macos?
                  "darwin"
                elsif windows?
                  "win32"
                else
                  "linux"
                end

source_url = "https://packages.chef.io/files/unstable/chef-workstation-app/#{version}/chef-workstation-app-#{version}-#{platform_name}.zip"
app_install_path = "#{install_dir}/components/chef-workstation-app"

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
    copy relative_path, app_install_path
  end
end



