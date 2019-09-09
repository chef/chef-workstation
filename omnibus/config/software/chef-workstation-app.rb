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

name "chef-workstation-app"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"

source git: "https://github.com/chef/chef-workstation-app"

# DO NOT MODIFY
# The Chef Workstation App version is pinned by Expeditor. Whenever Chef Workstation
# App is merged then Expeditor takes the latest tag, runs a script to replace it here
# and pushes a new commit / build through.
default_version "v0.1.5"
# /DO NOT MODIFY

# These electron dependencies are pulled in/created
# by this build. They may have dependendcies that aren't met
# on the install target - in which case the tray application
# will not be runnable.  That does not affect the rest of
# the chef-workstation installation, so we will whitelist the
# dependencies to allow it to continue in any case.
if linux?
  whitelist_file(%r{components/chef-workstation-app/libffmpeg\.so})
  whitelist_file(%r{components/chef-workstation-app/libGLESv2\.so})
  whitelist_file(%r{components/chef-workstation-app/chef-workstation-app})
end

build do
  block "do_build" do
    env = with_standard_compiler_flags(with_embedded_path)
    app_version = JSON.parse(File.read(File.join(project_dir, "package.json")))["version"]
    node_tools_dir = ENV["omnibus_nodejs_dir"]
    node_bin_path = windows? ? node_tools_dir : File.join(node_tools_dir, "bin")
    separator = File::PATH_SEPARATOR || ":"
    env["PATH"] = "#{env["PATH"]}#{separator}#{node_bin_path}"

    platform_name, artifact_name = if mac_os_x?
                                     ["mac", "Chef Workstation App-#{app_version}-mac.zip"]
                                   elsif linux?
                                     %w{linux linux-unpacked}
                                   elsif windows?
                                     %w{win win-unpacked}
                                   end

    dist_dir = File.join(project_dir, "dist")
    artifact_path = File.join(dist_dir, artifact_name)
    app_install_path = "#{install_dir}/components/chef-workstation-app"
    mkdir app_install_path

    # Ensure no leftover artifacts from a previous build -
    # electron-builder will recreate it:
    delete dist_dir

    npm_bin = File.join(node_bin_path, "npm")
    command "#{npm_bin} install", env: env
    command "#{npm_bin} run-script build-#{platform_name}", env: env

    if mac?
      target = File.join(app_install_path, "chef-workstation-app-#{platform_name}.zip")
      copy artifact_path, target
    else
      sync artifact_path, app_install_path
    end
  end
end
