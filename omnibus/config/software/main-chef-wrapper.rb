#
# Copyright 2019 Chef Software, Inc.
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

#
# @afiune This main wrapper will be our new 'chef' binary!
#
# It will understand the entire ecosystem in the Workstation world,
# things like 'chef generate foo'  and 'chef analyze bar'
name "main-chef-wrapper"
source path: File.join("#{project.files_path}", "../../components/main-chef-wrapper")
license :project_license

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"
  mkdir "#{install_dir}/bin"

  # @afiune Instead of using the chef-cli binary rename from https://github.com/chef/chef-cli/pull/35
  # I am making space by moving the binary. Once we can rename that binary we can remove this.
  if File.exist?("#{install_dir}/bin/chef")
    move "#{install_dir}/bin/chef", "#{install_dir}/bin/chef-cli"
  end

  # Windows does not support symlinks, so we need to use
  # the full path of the Go binary
  if windows?
    go_build_cmd = "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/chef.exe"
  else
    go_build_cmd = "go build -o #{install_dir}/bin/chef"
  end

  command go_build_cmd, env: env
end
