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

# The version-manifest.json contains all the omnibus definitions, but it does
# not list the gems installed as part of the bundle. This writes all those gems out
# so they are easy to locate and do not need to invoke ruby to determine or
# parse a gemfile.lock

# skip_transitive_dependency_licensing true
# license :project_license

# source path: "#{project.files_path}/#{name}"

# ruby "#{project_dir}/default/installed_gems_as_json.rb #{install_dir}/gem-version-manifest.json"

gem_home = Gem.paths.home

ruby "config/software/installed_gems_as_json.rb #{gem_home}/gem-version-manifest.json"
