#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
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

require "chef-run/action/install_chef/base"
require "chef-run/action/install_chef/windows"
require "chef-run/action/install_chef/linux"

module ChefRun::Action::InstallChef
  def self.instance_for_target(target_host, opts = { check_only: false })
    opts[:target_host] = target_host
    case target_host.base_os
    when :windows then Windows.new(opts)
    when :linux then Linux.new(opts)
    end
  end
end
