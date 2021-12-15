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

# The ruby-env.json contains all the omnibus env paths ex- gem_root, gem_home,
# and gem_path and other paths(used in cli), which can be used from go env for chef env

name "ruby-env-manifest"

skip_transitive_dependency_licensing true
license :project_license

source path: "#{project.files_path}/#{name}"

build do
  ruby "#{project_dir}/default/chef_cli_paths_as_json.rb #{install_dir}/ruby-env.json"
end
