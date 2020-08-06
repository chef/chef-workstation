#
# Copyright:: Chef Software, Inc.
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

name "azure-sdk"
default_version "master"

source git: "https://github.com/chef/azure-sdk-for-ruby.git"

license "MIT"
license_file "https://raw.githubusercontent.com/chef/azure-sdk-for-ruby/master/LICENSE.txt"

dependency "ruby"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  %w{compute key_vault network resources security storage}.each do |gem_name|
    gem "build azure_mgmt_#{gem_name}.gemspec", env: env, cwd: "#{project_dir}/management/azure_mgmt_#{gem_name}"
    gem "install azure_mgmt_#{gem_name}-*.gem --no-document --ignore-dependencies", env: env, cwd: "#{project_dir}/management/azure_mgmt_#{gem_name}"
  end
end
