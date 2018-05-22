#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
# License:: Apache License, Version 2.0
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

source "https://rubygems.org"
gemspec

# TODO when chef-dk 3.0 is released to Rubygems as 3.0 we can get rid of this
gem "chef-dk", git: "https://github.com/chef/chef-dk.git", branch: "master"

gem "train", git: "https://github.com/chef/train.git", branch: "v1.4.6"

group :localdev do
  gem "irbtools-more", require: "irbtools/binding"
end
