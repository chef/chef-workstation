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
require "chef-workstation/remote-connection"
require "chef-workstation/action/install-chef"
require "chef-workstation/action/converge-target"
require "chef-workstation/ui/terminal"

module ChefWorkstation
  module Command
    class Target
      class Converge < ChefWorkstation::Command::Base
        # This is just an example here to show that we can set options at this level
        option :root,
          :long => "--root",
          :description => Text.commands.target.converge.root_description,
          :boolean => true,
          :default => true

        option :identity_file,
          :long => "--identity-file PATH",
          :short => "-i PATH",
          :description => Text.commands.target.converge.identity_file

        def run(params)
          # TODO ensure it really is, set up usage.
          # TODO: option: --no-install
          target = params.shift
          resource = params.shift
          resource_name = params.shift

          full_rs_name = "#{resource}[#{resource_name}]"
          conn = nil
          UI::Terminal.output "Converging #{target} with #{full_rs_name} using the default action"
          UI::Terminal.spinner("Connecting...", prefix: "[#{target}]") do |status_reporter|
            conn = RemoteConnection.make_connection(target, { sudo: config[:root], key_file: config[:identity_file] } )
            conn.run_command("sudo ls")
            status_reporter.success("Connected - using config specified in ~/.ssh/config")
          end
          UI::Terminal.spinner("Installing Chef Client...", prefix: "[#{target}]") do |status_reporter|
            Action::InstallChef.new(connection: conn, reporter: status_reporter).run
            # status_reporter.success("...")
          end
          UI::Terminal.spinner("Converging #{full_rs_name}...", prefix: "[#{target}]") do |status_reporter|
            # Action::ConvergeTarget.new(connection: conn).run
            c = conn.run_command("/opt/chef/bin/chef-apply -e \"#{resource} '#{resource_name}'\"")
            if c.exit_status == 0
              status_reporter.success("Successfully converged #{full_rs_name}!")
              ChefWorkstation::Log.debug(c.stdout)
            else
              status_reporter.error("Failed to converge remote machine. See detailed log")
              ChefWorkstation::Log.error("Chef workstation error: \n    "+c.stdout.split("\n").join("\n    "))
            end
          end

          0
        end
      end
    end
  end
end
