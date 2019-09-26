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

name "chef-analyze"
# TODO @afiune point to master when SPIKE is done: cphttps://github.com/chef/chef-workstation/issues/497
default_version "1abd9d66682f42707eff0dd0652ddb791953b30c"
license "Apache-2.0"
license_file "LICENSE"
source git: "https://github.com/chef/chef-analyze.git"

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"
  mkdir "#{install_dir}/bin"
  command "go build -o #{install_dir}/bin/#{name}", env: env
end
