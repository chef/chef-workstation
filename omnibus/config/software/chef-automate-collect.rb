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

# This will be our rollout client for publishing policy changes
#
name "chef-automate-collect"
source path: File.join("#{project.files_path}", "../../components/chef-automate-collect")
license :project_license

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"

  if windows?
    # Windows systems requires an extention (EXE)
    go "build -o #{install_dir}/bin/chef-automate-collect.exe", env: env

    block "Generate a 'chef-automate-collect' binary that calls the 'chef-automate-collect.exe' executable" do
      File.open("#{install_dir}/bin/chef-automate-collect", "w") do |f|
        f.write("@ECHO OFF\n\"%~dpn0.exe\" %*")
      end
    end
  else
    # Unix systems has no extention
    go "build -o #{install_dir}/bin/chef-automate-collect", env: env
  end
end
