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
require "chef-workstation/recipe_path"

module ChefWorkstation
  module Command
    class Target
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

        option :chef_repo_path,
          :long => "--chef-repo-path",
          :description => T.chef_repo_path.desc

        def run(params)
          validate_params(cli_arguments)

          target = cli_arguments.shift

          @conn = connect(target, config)
          UI::Terminal.spinner(TS.install.verifying, prefix: "[#{@conn.hostname}]") do |r|
            install(r)
          end

          converge_args = { connection: @conn }
          converge_args, spinner_msg = parse_converge_args(converge_args, cli_arguments)
          UI::Terminal.spinner(spinner_msg, prefix: "[#{@conn.hostname}]") do |r|
            converge(r, converge_args)
          end
        end

        # The first param is always hostname. Then we either have
        # 1. A recipe designation
        # 2. A resource type and resource name followed by any properties
        PROPERTY_MATCHER = /^([a-zA-Z0-9]+)=(.+)$/
        CB_MATCHER = '[\w\-]+'
        def validate_params(params)
          if params.size < 2
            raise OptionValidationError.new("CHEFVAL002")
          end
          if params.size == 2
            # Trying to specify a recipe to run remotely, no properties
            cb = params[1]
            if File.exist?(cb)
              # This is a path specification, and we know it is valid
            elsif cb =~ /^#{CB_MATCHER}$/ || cb =~ /^#{CB_MATCHER}::#{CB_MATCHER}$/
              # They are specifying a cookbook as 'cb_name' or 'cb_name::recipe'
            else
              raise OptionValidationError.new("CHEFVAL004", cb)
            end
          elsif params.size >= 3
            properties = params[3..-1]
            properties.each do |property|
              unless property =~ PROPERTY_MATCHER
                raise OptionValidationError.new("CHEFVAL003", property)
              end
            end
          end
        end

        def format_properties(string_props)
          properties = {}
          string_props.each do |a|
            key, value = PROPERTY_MATCHER.match(a)[1..-1]
            value = transform_property_value(value)
            properties[key] = value
          end
          properties
        end

          # Incoming properties are always read as a string from the command line.
          # Depending on their type we should transform them so we do not try and pass
          # a string to a resource property that expects an integer or boolean.
        def transform_property_value(value)
          case value
          when /^0/
            # when it is a zero leading value like "0777" don't turn
            # it into a number (this is a mode flag)
            value
          when /^\d+$/
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

        # The user will either specify a single resource on the command line, or a recipe.
        # We need to parse out those two different situations
        def parse_converge_args(converge_args, cli_arguments)
          if recipe_strategy?(cli_arguments)
            recipe_specifier = cli_arguments.shift
            ChefWorkstation::Log.debug("Beginning to look for recipe specified as #{recipe_specifier}")
            recipe_path = RecipePath.resolve(recipe_specifier)
            converge_args[:recipe_path] = recipe_path
            spinner_msg = TS.converge.converging_recipe(recipe_specifier)
          else
            converge_args[:resource_type] = cli_arguments.shift
            converge_args[:resource_name] = cli_arguments.shift
            converge_args[:properties] = format_properties(cli_arguments)
            full_rs_name = "#{converge_args[:resource_type]}[#{converge_args[:resource_name]}]"
            ChefWorkstation::Log.debug("Converging resource #{full_rs_name} on target")
            spinner_msg = TS.converge.converging_resource(full_rs_name)
          end

          [converge_args, spinner_msg]
        end

        def recipe_strategy?(cli_arguments)
          cli_arguments.size == 1
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
        def converge(reporter, converge_args)
          converger = Action::ConvergeTarget.new(converge_args)
          converger.run do |event, data|
            case event
            when :success
              reporter.update(TS.converge.success)
            when :error
              reporter.error(TS.converge.failure)
            end
          end
        end

      end
    end
  end
end
