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
          :long => "--root",
          :description => T.root_description,
          :boolean => true,
          :default => true

        option :identity_file,
          :long => "--identity-file PATH",
          :short => "-i PATH",
          :description => T.identity_file

        def run(params)
          # TODO ensure it really is, set up usage.
          # TODO: option: --no-install
          target = params.shift
          resource = params.shift
          resource_name = params.shift
          full_rs_name = "#{resource}[#{resource_name}]"

          conn = connect(target, { sudo: config[:root], key_file: config[:identity_file] })

          UI::Terminal.spinner(T.status.converge.verifying) do |r|
            install_chef(r, conn)
          end


          UI::Terminal.spinner(T.status.converging(full_rs_name).to_s, prefix: "[#{target}]") do |r|
            converge(r, conn, resource_type, resource_name)
          end
          0
        end

        def install_chef(reporter)
          installer = Action::InstallChef.new(connection: conn)
          run_action(installer) do |event, data|
            install_event_handler(reporter, event, data)

          end
        end

        def install_event_handler(reporter, event, data)
          case event
          when :downloading
            reporter.update(T.status.downloading)
          when :uploading
            reporter.update(T.status.uploading)
          when :installing
            reporter.update(T.status.installing)
          when :success
            if data == :install_complete
              reporter.update(T.status.success_installed)
            else # :already_installed
              reporter.update(T.status.client_already_installed)
            end
          when :exception
            # # TODO capture excpetion, proper formatting, etc etc
            reporter.failure(data.message)
          end
        end

        def converge(reporter, res_type, res_name)
          c = Action::ConvergeTarget.new(connection: conn,
                                         resource_type: res_type,
                                         resource_name: res_name)
          run_action(c) do |event, data|
            case event
            when :success
            when :failure
            end
          end

        end


      end
    end
  end
end
