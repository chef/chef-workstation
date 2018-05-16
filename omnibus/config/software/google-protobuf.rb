#
# Copyright 2018 Chef Software, Inc.
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

### NOTE ###
# We build this definition from source rather than installing from the
# gem so the native extension builds against the correct ruby rather than shipping
# a vendored library for each 2.x version of ruby, which is what is packaged
# with the gem.

name 'google-protobuf'
default_version 'v3.5.2'

dependency 'ruby'
dependency 'rubygems'

source git: "https://github.com/google/protobuf.git"

license :project_license

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem "build google-protobuf.gemspec", env: env, cwd: "#{project_dir}/ruby"
  gem "install google-protobuf-*.gem", env: env, cwd: "#{project_dir}/ruby"
end