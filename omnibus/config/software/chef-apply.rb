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

name "chef-apply"
default_version "master"

license :project_license

source git: "https://github.com/chef/chef-apply.git"

dependency "rubygems"
dependency "bundler"
dependency "ruby"
dependency "appbundler"
dependency "chef-dk"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  bundle "install --without development", env: env
  gem "build chef-apply.gemspec", env: env
  gem "install chef-apply*.gem" \
      " --no-ri --no-rdoc" \
      " --force" \
      " --verbose --without development", env: env

  appbundle "chef-apply", lockdir: project_dir, without: %w{development localdev}, gem: 'chef-apply', env: env
end
