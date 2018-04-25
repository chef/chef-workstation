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
require "chef-workstation/target_host"
require "chef-workstation/action/install_chef"
require "chef-workstation/action/converge_target"
require "chef-workstation/ui/terminal"
require "chef-workstation/log"
require "chef-workstation/config"
require "chef-workstation/recipe_lookup"
require "chef-config/config"
require "chef-config/logger"
require "chef/log"

module ChefWorkstation
  module Command
    class Target
      class Converge < ChefWorkstation::Command::Base
        T = ChefWorkstation::Text.commands.target.converge
        TS = ChefWorkstation::Text.status

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
              raise OptionValidationError.new("CHEFVAL001", self, path)
            end
            path
          end)

        option :ssl,
          :long => "--[no-]ssl",
          :short => "-s",
          :description => T.ssl.desc(ChefWorkstation::Config.connection.winrm.ssl),
          :boolean => true,
          :default => ChefWorkstation::Config.connection.winrm.ssl

        option :ssl_verify,
          :long => "--[no-]ssl-verify",
          :short => "-s",
          :description => T.ssl.verify_desc(ChefWorkstation::Config.connection.winrm.ssl_verify),
          :boolean => true,
          :default => ChefWorkstation::Config.connection.winrm.ssl_verify

        option :cookbook_repo_paths,
          :long => "--cookbook-repo-paths PATH",
          :description => T.cookbook_repo_paths.desc,
          :default => ChefWorkstation::Config.chef.cookbook_repo_paths,
          :proc => Proc.new { |paths| paths.split(",") }

        def run(params)
          validate_params(cli_arguments)
          configure_chef

          target = cli_arguments.shift

          @conn = connect(target, config)
          UI::Terminal.spinner(TS.install_chef.verifying, prefix: "[#{@conn.hostname}]") do |r|
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
            raise OptionValidationError.new("CHEFVAL002", self)
          end
          if params.size == 2
            # Trying to specify a recipe to run remotely, no properties
            cb = params[1]
            if File.exist?(cb)
              # This is a path specification, and we know it is valid
            elsif cb =~ /^#{CB_MATCHER}$/ || cb =~ /^#{CB_MATCHER}::#{CB_MATCHER}$/
              # They are specifying a cookbook as 'cb_name' or 'cb_name::recipe'
            else
              raise OptionValidationError.new("CHEFVAL004", self, cb)
            end
          elsif params.size >= 3
            properties = params[3..-1]
            properties.each do |property|
              unless property =~ PROPERTY_MATCHER
                raise OptionValidationError.new("CHEFVAL003", self, property)
              end
            end
          end
        end

        # Now that we are leveraging Chef locally we want to perform some initial setup of it
        def configure_chef
          ChefConfig.logger = ChefWorkstation::Log
          # Setting the config isn't enough, we need to ensure the logger is initialized
          # or automatic initialization will still go to stdout
          Chef::Log.init(ChefWorkstation::Log)
          Chef::Log.level = ChefWorkstation::Log.level
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
            if File.file?(recipe_specifier)
              ChefWorkstation::Log.debug("#{recipe_specifier} is a valid path to a recipe")
              recipe_path = recipe_specifier
            else
              rl = RecipeLookup.new(config[:cookbook_repo_paths])
              cookbook_path_or_name, optional_recipe_name = rl.split(recipe_specifier)
              cookbook = rl.load_cookbook(cookbook_path_or_name)
              recipe_path = rl.find_recipe(cookbook, optional_recipe_name)
            end
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
          context = Text.status.install_chef
          installer.run do |event, data|
            case event
            when :installing
              r.update(context.installing)
            when :uploading
              r.update(context.uploading)
            when :downloading
              r.update(context.downloading)
            when :success
              if data[0] == :already_installed
                r.success(context.already_present)
              elsif data[0] == :install_success
                r.success(context.success)
              end
            when :error
              # Message may or may not be present. First arg if it is.
              msg = data.length > 0 ? data[0] : T.aborted
              r.error(context.failure(msg))
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
