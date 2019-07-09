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
  whitelist_file(/components\/chef-workstation-app\/libffmpeg\.so/)
  whitelist_file(/components\/chef-workstation-app\/chef-workstation-app/)
end

build do
  block "do_build" do
  end
end
