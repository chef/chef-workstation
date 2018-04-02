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
          :proc => (Proc.new do |path|
            unless File.exist?(path)
              raise OptionValidationError.new("CHEFVAL001", path)
            end
            path
          end)

        def run(params)
          validate_params(cli_arguments)
          # TODO: option: --no-install
          target = cli_arguments.shift
          resource = cli_arguments.shift
          resource_name = cli_arguments.shift
          attributes = format_attributes(cli_arguments)

          conn = connect(target, { sudo: config[:root], key_file: config[:identity_file] })
          UI::Terminal.spinner(T.status.verifying, prefix: "[#{conn.config[:host]}]") do |r|
            Action::InstallChef.instance_for_target(conn, reporter: r).run
          end

          full_rs_name = "#{resource}[#{resource_name}]"
          UI::Terminal.spinner(T.status.converging(full_rs_name), prefix: "[#{conn.config[:host]}]") do |r|
            converger = Action::ConvergeTarget.new(reporter: r,
                                                   connection: conn,
                                                   resource_type: resource,
                                                   resource_name: resource_name,
                                                   attributes: attributes)
            converger.run
          end
        end

        ATTRIBUTE_MATCHER = /^([a-zA-Z0-9]+)=(.+)$/
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

      end
    end
  end
end
