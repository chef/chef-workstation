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

require "mixlib/cli"
require "chef-workstation/config"
require "chef-workstation/text"
require "chef-workstation/log"
require "chef-workstation/error"
require "chef-workstation/ui/terminal"

module ChefWorkstation
  module Command
    class Base
      include Mixlib::CLI
      T = Text.commands.base

      # All the actual commands have their banner managed and set from the commands map
      # Look there to see how we set this in #create
      banner "Command banner not set."

      option :version,
        :short        => "-v",
        :long         => "--version",
        :description  => Text.commands.version.description,
        :boolean      => true

      option :help,
        :short        => "-h",
        :long         => "--help",
        :description  => Text.commands.help.description,
        :boolean      => true

      option :config_path,
        :short        => "-c PATH",
        :long         => "--config PATH",
        :description  => T.config(ChefWorkstation::Config.default_location),
        :default      => ChefWorkstation::Config.default_location,
        :proc         => Proc.new { |path| ChefWorkstation::Config.custom_location(path) }

      def initialize(command_spec)
        @command_spec = command_spec
        @root_command = @command_spec.qualified_name == "hidden-root"
        super()
        # Replace top-level command help description with one specific to the
        # command being run
        if !@root_command
          options[:help][:description] = T.help_for(@command_spec.qualified_name)
        end
      end

      def run_with_default_options(params = [])
        parse_options(params)
        if config[:help]
          show_help
        else
          run(params)
        end
      end

      # This is normally overridden by the command implementations, but
      # can execute in the case of 'chef' being run with no arguments.
      def run(params)
        show_help
      end

      # Accepts a target_host and establishes the connection to that host
      # while providing visual feedback via the Terminal API.
      def connect_target(target_host, reporter = nil)
        if reporter.nil?
          UI::Terminal.spinner(T.status.connecting, prefix: "[#{target_host.config[:host]}]") do |rep|
            target_host.connect!
            rep.success(T.status.connected)
          end
        else
          reporter.update(T.status.connecting)
          target_host.connect!
          # No success here - if we have a reporter,
          # it's because it will be used for more actions than our own
          # and success marks the end.
          reporter.update(T.status.connected)
        end
        target_host
      rescue RuntimeError => e
        if reporter.nil?
          UI::Terminal.output(e.message)
        else
          reporter.error(e.message)
        end
        raise
      end

      def self.usage(usage = nil)
        if usage.nil?
          @usage
        else
          @usage = usage
        end
      end

      def usage
        self.class.usage
      end

      private

      # TODO - does this all just belong in a HelpFormatter? Seems weird
      # to encumber the base with all this...
      def show_help
        if @root_command
          UI::Terminal.output T.version_for_help(ChefWorkstation::VERSION)
        end
        UI::Terminal.output banner
        show_help_flags unless options.empty?
        show_help_subcommands unless subcommands.empty?
        if @root_command && ChefWorkstation.commands_map.alias_specs.length > 0
          show_help_aliases
        end
      end

      def show_help_flags
        UI::Terminal.output ""
        UI::Terminal.output "FLAGS:"
        justify_length = 0
        options.each_value do |spec|
          justify_length = [justify_length, spec[:long].length + 4].max
        end
        options.sort.to_h.each_value do |flag_spec|
          short = flag_spec[:short] || "  "
          short = short[0, 2] # We only want the flag portion, not the capture portion (if present)
          if short == "  "
            short = "    "
          else
            short = "#{short}, "
          end
          flags = "#{short}#{flag_spec[:long]}"
          UI::Terminal.write("    #{flags.ljust(justify_length)}    ")
          ml_padding = " " * (justify_length + 8)
          first = true
          flag_spec[:description].split("\n").each do |d|
            UI::Terminal.write(ml_padding) unless first
            first = false
            UI::Terminal.write(d)
            UI::Terminal.write("\n")
          end
        end
      end

      def show_help_subcommands
        UI::Terminal.output ""
        UI::Terminal.output "SUBCOMMANDS:"
        justify_length = ([7] + subcommands.keys.map(&:length)).max + 4
        display_subcmds = subcommands.keys.sort
        # A bit of management to ensure that 'help' and version are the last displayed subcommands

        # Ensure help and version show up last - remove them from
        # current location and append them.
        if display_subcmds.include? "help"
          display_subcmds << display_subcmds.delete("help")
        end
        if display_subcmds.include? "version"
          display_subcmds << display_subcmds.delete("version")
        end
        display_subcmds.each do |name|
          spec = subcommands[name]
          next if spec.hidden
          UI::Terminal.output "    #{"#{name}".ljust(justify_length)}#{spec.text.description}"
        end
      end

      def show_help_aliases
        justify_length = ([7] + ChefWorkstation.commands_map.alias_specs.keys.map(&:length)).max + 4
        UI::Terminal.output ""
        UI::Terminal.output(T.aliases)
        ChefWorkstation.commands_map.alias_specs.sort.each do |name, spec|
          next if spec.hidden
          UI::Terminal.output "    #{"#{name}".ljust(justify_length)}#{T.alias_for} '#{spec.qualified_name}'"
        end
      end

      def subcommands
        # The base class behavior subcommands are actually the full list
        # of top-level commands - those are subcommands of 'chef'.
        # In a future pass, we may want to actually structure it that way
        # such that a "Base' instance named 'chef' is the root command.
        @command_spec.subcommands
      end

      class OptionValidationError < ChefWorkstation::ErrorNoLogs
        attr_reader :command
        def initialize(id, calling_command, *args)
          super(id, *args)
          # TODO - this is getting cumbersome - move them to constructor options hash in base
          @decorate = false
          @command = calling_command
        end
      end

    end
  end
end
