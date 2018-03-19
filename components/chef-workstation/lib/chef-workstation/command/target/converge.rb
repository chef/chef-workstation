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

require "chef-workstation/command/base"
require "chef-workstation/command/target"
require "chef-workstation/remote_connection"
require "chef-workstation/action/install_chef"
require "chef-workstation/action/converge_target"
require "chef-workstation/ui/terminal"

module ChefWorkstation
  module Command
    class Target
      class Converge < ChefWorkstation::Command::Base
        # Text Context is just the
        T = Text.commands.target.converge
        option :root,
          :long => "--root",
          :description => T.usage.root_description,
          :boolean => true,
          :default => true

        option :identity_file,
          :long => "--identity-file PATH",
          :short => "-i PATH",
          :description => T.usage.identity_file

        def run(params)
          # TODO ensure it really is, set up usage.
          # TODO: option: --no-install
          target = params.shift
          resource = params.shift
          resource_name = params.shift
          full_rs_name = "#{resource}[#{resource_name}]"

          conn = connect({sudo: config[:root], key_file: config[:identity_file]})

          UI::Terminal.spinner("Verifying Chef client installation...") do |r|
            installer = Action::InstallChef.new(connection: conn, reporter: r)
            installer.run
          end

          UI::Terminal.spinner("Converging #{full_rs_name}...", prefix: "[#{target}]") do |r|
            converger = Action::ConvergeTarget.new(reporter: r,
                                                   connection: conn,
                                                   resource_type: resource,
                                                   resource_name: resource_name)
            converger.run
          end
          0
        end

      end
    end
  end
end
