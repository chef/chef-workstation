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
require "chef-workstation/log"
require "chef-workstation/config"

module ChefWorkstation
  module Command
    class Target
      ATTRIBUTE_MATCHER = /^([a-zA-Z0-9]+)=(.+)$/
      class Converge < ChefWorkstation::Command::Base
        T = ChefWorkstation::Text.commands.target.converge
        TS = ChefWorkstation::Text.status
        Config = ChefWorkstation::Config

        option :root,
          :long => "--[no-]root",
          :description => T.root_description,
          :boolean => true,
          :default => true

        option :identity_file,
          :long => "--identity-file PATH",
          :short => "-i PATH",
          :description => T.identity_file,
          :proc => (Proc.new do |path|
            unless File.exist?(path)
              raise OptionValidationError.new("CHEFVAL001", path)
            end
            path
          end)

        option :ssl,
          :long => "--[no-]ssl",
          :short => "-s",
          :description => T.ssl.desc(Config.connection.winrm.ssl),
          :boolean => true,
          :default => Config.connection.winrm.ssl

        option :ssl_verify,
          :long => "--[no-]ssl-verify",
          :short => "-s",
          :description => T.ssl.verify_desc(Config.connection.winrm.ssl_verify),
          :boolean => true,
          :default => Config.connection.winrm.ssl_verify

        def run(params)
          validate_params(cli_arguments)
          # TODO: option: --no-install
          target = cli_arguments.shift
          @resource = cli_arguments.shift
          @resource_name = cli_arguments.shift
          full_rs_name = "#{@resource}[#{@resource_name}]"
          @attributes = format_attributes(cli_arguments)
          @conn = connect(target, config)

          UI::Terminal.spinner(TS.install.verifying, prefix: "[#{@conn.hostname}]") do |r|
            install(r)
          end

          UI::Terminal.spinner(TS.converge.converging(full_rs_name), prefix: "[#{@conn.hostname}]") do |r|
            converge(r, full_rs_name)
          end
        end

        def validate_params(params)
          if params.size < 3
            raise OptionValidationError.new("CHEFVAL002")
          end
          attributes = params[3..-1]
          attributes.each do |attribute|
            unless attribute =~ ATTRIBUTE_MATCHER
              raise OptionValidationError.new("CHEFVAL003", attribute)
            end
          end
        end

        def format_attributes(string_attrs)
          attributes = {}
          string_attrs.each do |a|
            key, value = ATTRIBUTE_MATCHER.match(a)[1..-1]
            value = transform_attribute_value(value)
            attributes[key] = value
          end
          attributes
        end

          # Incoming attributes are always read as a string from the command line.
          # Depending on their type we should transform them so we do not try and pass
          # a string to a resource attribute that expects an integer or boolean.
        def transform_attribute_value(value)
          case value
          when /^0/
            # when it is a zero leading value like "0777" don't turn
            # it into a number (this is a mode flag)
            value
          when /\d+/
            value.to_i
          when /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/
            value.to_f
          when /true/i
            true
          when /false/i
            false
          else
            value
          end
        end

          # Runs the InstallChef action and renders UI updates as
          # the action reports back
        def install(r)
          installer = Action::InstallChef.instance_for_target(@conn)
          installer.run do |event, data|
            case event
            when :installing
              r.update(TS.install.installing)
            when :uploading
              r.update(TS.install.uploading)
            when :downloading
              r.update(TS.install.downloading)
            when :success
              if data[0] == :already_installed
                r.success(TS.install.already_present)
              elsif data[0] == :install_success
                r.success(TS.install.success)
              end
            when :error
              # Message may or may not be present. First arg if it is.
              msg = data.length > 0 ? data[0] : Text.cli.aborted
              r.error(TS.install.failure(msg))
            end
          end
        end

          # Runs the Converge action and renders UI updates as
          # the action reports back
        def converge(r, full_rs_name)
          converger = Action::ConvergeTarget.new(connection: @conn,
                                                 resource_type: @resource,
                                                 resource_name: @resource_name,
                                                 attributes: @attributes)
          converger.run do |event, data|
            case event
            when :success
              r.update(TS.converge.success(full_rs_name))
            when :error
              r.error(TS.converge.failure)
            end
          end
        end

      end
    end
  end
end
