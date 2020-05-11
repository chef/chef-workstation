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

name "foodcritic-wrapper"
source path: File.join("#{project.files_path}", "../../components/foodcritic-wrapper")
license :project_license

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "0"

  # Rename foodcritic appbundle and put our shim in its place
  # TODO what are these on Windows?
  move "#{install_dir}/bin/foodcritic", "#{install_dir}/bin/_foodcritic"

  if windows?
    # Windows systems requires an extention (EXE)
    command "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/foodcritic.exe", env: env

    block "Generate a 'foodcritic' binary that calls the 'foodcritic.exe' executable" do
      File.open("#{install_dir}/bin/foodcritic", "w") do |f|
        f.write("@ECHO OFF\n\"%~dpn0.exe\" %*")
      end
    end
  else
    # Unix systems has no extention
    command "#{install_dir}/embedded/go/bin/go build -o #{install_dir}/bin/foodcritic", env: env
  end
end
