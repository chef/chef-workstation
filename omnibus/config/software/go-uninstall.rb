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
# expeditor/ignore: logic only

name "go-uninstall"
default_version "0.0.1"
license :project_license
dependency "go"

build do
  # Until Omnibus has full support for build depedencies (see chef/omnibus#483)
  # we are going to manually uninstall Go
  %w{go gofmt}.each do |bin|
    delete "#{install_dir}/embedded/bin/#{bin}"
  end

  block "Delete Go language from embedded directory" do
    remove_directory "#{install_dir}/embedded/go"
  end
end
