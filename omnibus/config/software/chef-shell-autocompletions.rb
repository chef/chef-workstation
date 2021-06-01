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

name "chef-shell-autocompletions"

source path: "#{project.files_path}/chef-shell-autocompletions"

skip_transitive_dependency_licensing true
license :project_license

build do
    copy "#{project_dir}/chef-shell-init", "#{install_dir}/bin/chef-shell-init", { preserve: true }
end
