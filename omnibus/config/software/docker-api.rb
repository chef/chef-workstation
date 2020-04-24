#
# Copyright 2012-2020 Chef Software, Inc.
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

name "docker-api"
default_version "master"

source git: "https://github.com/chef/docker-api.git"

license "MIT"
license_file "https://raw.githubusercontent.com/chef/docker-api/master/LICENSE"

dependency "ruby"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # docker-api does not have any unique dependencies not already
  # included in Chef Workstation. We let the master gem bundle
  # install those gems. If we ever add custom dependencies into
  # our fork we need to re-add bundle install here for make the
  # gemfile pull from the fork and don't build here.
  # bundle "install", env: env
  gem "build docker-api.gemspec", env: env
  gem "install docker-api-*.gem --no-document --ignore-dependencies", env: env
end
