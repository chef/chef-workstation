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

        def run(params)
          # TODO ensure it really is, set up usage.
          # TODO: option: --no-install
          target = params.shift
          resource = params.shift
          resource_name = params.shift

          # conn = RemoteConnection.new(target, { sudo: options[:root] })
          # # These puts will be replaced with actual prgoress reports through
          # # whatever UI interface we settle on.
          # puts "Connecting"
          # # TODO it seems a bit cumbersome, but it might be a bit cleaner if we
          # # define a "connect" action - then we'd basically be looking at a given command
          # # just running a sequence of one or more Actions. It would be interesting to explore something
          # # like having each command just return a list of chained actions that the base class executes.
          # conn.connect!
          # puts "Checking and uploading"
          # Action::InstallChef.new(connection: conn).run
          # puts "Later, I'll converge something!"

          full_rs_name = "#{resource}[#{resource_name}]"
          UI::Terminal.output "Converging #{target} with #{full_rs_name} using the default action"
          UI::Terminal.spinner("Connecting...", prefix: "[#{target}]") do |status_reporter|
            conn = RemoteConnection.new(target, { sudo: options[:root] })
            conn.connect!
            conn.run_command("sudo ls")
            status_reporter.success("Connected - using config specified in ~/.ssh/config")
          end
          # UI::Terminal.spinner("Performing first time setup...", prefix: "[#{target}]") do |status_reporter|
          #   # install chef
          #   sleep 3
          #   status_reporter.success("First time setup completed successfully!")
          # end
          # UI::Terminal.spinner("Converging #{full_rs_name}...", prefix: "[#{target}]") do |status_reporter|
          #   # install chef
          #   sleep 3
          #   status_reporter.success("#{full_rs_name} converged successfully!")
          # end

          0
        end
      end
    end
  end
end
