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
        T = Text.commands.target.converge
        option :root,
          :long => "--[no-]root",
          :description => T.root_description,
          :boolean => true,
          :default => true

        option :identity_file,
          :long => "--identity-file PATH",
          :short => "-i PATH",
          :description => T.identity_file,
          # TODO unique error code, make sure this works with SHACK-105
          :proc => Proc.new { |path| raise "No identity file at #{path}" unless File.exist?(path) }

        def run(params)
          # TODO: option: --no-install
          target = params.shift
          resource = params.shift
          resource_name = params.shift
          full_rs_name = "#{resource}[#{resource_name}]"

          conn = connect(target, { sudo: config[:root], key_file: config[:identity_file] })
          UI::Terminal.spinner(T.status.verifying, prefix: "[#{conn.config[:host]}]") do |r|
            Action::InstallChef.instance_for_target(conn, reporter: r).run
          end

          UI::Terminal.spinner(T.status.converging(full_rs_name), prefix: "[#{conn.config[:host]}]") do |r|
            converger = Action::ConvergeTarget.new(reporter: r,
                                                   connection: conn,
                                                   resource_type: resource,
                                                   resource_name: resource_name)
            converger.run
          end
        end
      end
    end
  end
end
