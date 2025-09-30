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

name "notice-file"

skip_transitive_dependency_licensing true
license :project_license

source path: File.join("#{project.files_path}", "../../")

build do
  # Copy NOTICE file to the install directory
  copy "#{project_dir}/NOTICE", "#{install_dir}/NOTICE"
end