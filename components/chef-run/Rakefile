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

require "bundler/gem_tasks"

task :default => [:spec, :style]

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "chefstyle"
require "rubocop/rake_task"
desc "Run Chef Ruby style checks"
RuboCop::RakeTask.new(:chefstyle) do |t|
  t.options = %w{--display-cop-names}
end

task :style => :chefstyle
