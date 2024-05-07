#
# Copyright:: Copyright (c) Chef Software Inc.
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

name "c_rehash_ruby"
default_version "main"
license "Apache-2.0"
license_file "LICENSE"

source path: File.join("#{project.files_path}", "../../components/rehash")

build do
  # Copy the file from the source to the bin directory
  copy "#{project_dir}/c_rehash.rb", "#{install_dir}/embedded/bin/c_rehash_ruby"
  # Set the executable permission for the script
  command("chmod +x #{install_dir}/embedded/bin/c_rehash_ruby")
end
