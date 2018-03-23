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

name "chef-workstation"
default_version "local_source"

license :project_license

# For the specific super-special version "local_source", build the source from
# the local git checkout. This is what you'd want to occur by default if you
# just ran omnibus build locally.
version("local_source") do
  source path: File.expand_path("#{project.files_path}/../../components/chef-workstation")
end

# For any version other than "local_source", fetch from github.
if version != "local_source"
  source git: "https://github.com/chef/chef-workstation.git"
end

dependency "rubygems"
dependency "bundler"
dependency "ruby"
dependency "appbundler"
dependency "version-manifest"

relative_path "components/chef-workstation"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  bundle "install --without development", env: env
  gem "build chef-workstation.gemspec", env: env
  gem "install chef-workstation*.gem" \
      " --no-ri --no-rdoc" \
      " --verbose --without development", env: env

  appbundle "chef-workstation", lockdir: project_dir, without: %w{development}, env: env
end
