#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
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
require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/version"
require "chef-workstation/telemetry"
require "chef-workstation/commands_map"
require "chef-workstation/builtin_commands"
require "chef-workstation/text"
require "chef-workstation/error"
require "chef-workstation/ui/terminal"
require "chef-workstation/ui/error_printer"
require "mixlib/cli"

module ChefWorkstation
  class CLI
    include Mixlib::CLI
    T = ChefWorkstation::Text.cli
    RC_COMMAND_FAILED = 1
    RC_ERROR_HANDLING_FAILED = 64

    banner T.banner

    option :version,
      :long         => "--version",
      :description  => T.version,
      :boolean      => true

    option :help,
      :short        => "-h",
      :long         => "--help",
      :description  => T.help,
      :boolean      => true

    option :config_path,
      :short        => "-c PATH",
      :long         => "--config PATH",
      :description  => T.config(Config.default_location),
      :default      => Config.default_location,
      :proc         => Proc.new { |path| Config.custom_location(path) }

    def initialize(argv)
      @argv = argv
      @rc = 0
      super()
    end

    def run
      init
      # Perform a timing and capture of the requested command. Individual
      # commands and components may perform nested Telemetry.timed_capture or Telemetry.capture
      # calls in their operation.
      Telemetry.timed_capture(:run, command: @command,
                                    sub: @subcommand, args: @argv,
                                    opts: options.to_h) { perform_command() }
    rescue WrappedError => e
      UI::ErrorPrinter.show_error(e)
      @rc = RC_COMMAND_FAILED
    rescue => e
      UI::ErrorPrinter.dump_unexpected_error(e)
      @rc = RC_ERROR_HANDLING_FAILED
    ensure
      Telemetry.send!
      exit @rc
    end

    def init
      # Creates the tree we need under ~/.chef-workstation
      # based on config settings:
      Config.create_directory_tree
      if Config.using_default_location? && !Config.exist?
        UI::Terminal.output T.creating_config(Config.default_location)
        Config.create_default_config_file
      end
      Config.load
      ChefWorkstation::Log.setup(Config.log.location)
      Log.level = Config.log.level.to_sym
      ChefWorkstation::Log.info("Initialized logger")
      # Enable CLI output via Terminal
      UI::Terminal.init
    end

    def perform_command
      command_name, *command_params = @argv
      if command_name.nil? || %w{help -h --help}.include?(command_name.downcase)
        if command_params.empty?
          UI::Terminal.output(T.print_version(ChefWorkstation::VERSION))
          show_help
          return
        else
          # They are trying to get help text on something else - like `chef help converge`
          # We pass down the help flag to the actual class they are trying to get help text on
          command_name = command_params.shift
          command_params << "-h"
        end
      elsif %w{version --version}.include?(command_name.downcase)
        UI::Terminal.output ChefWorkstation::VERSION
        return
      end

      if have_command?(command_name)
        @cmd, command_params = commands_map.instantiate(command_name, command_params)
        @cmd.run_with_default_options(command_params)
      else
        raise UnknownCommand.new(command_name, commands.join(" "))
      end
    rescue => e
      handle_perform_error(e)
    end

    def handle_perform_error(e)
      id = e.respond_to?(:id) ? e.id : e.class.to_s
      message = e.respond_to?(:message) ? e.message : e.to_s
      Telemetry.capture(:error, exception: { id: id, message: message })
      # TODO: connection assignment below won't work, because the connection is internal the
      #       action that failed. We can work around this for CW::Error-derived errors by accepting connection
      #       in the constructor; but we still need to find a happy path for third-party errors
      #       (train, runtime) - perhaps moving connection tracking and lookup to its own component
      #
      # #conn = @cmd.nil? ? nil : @cmd.connection
      conn = nil
      wrapper = ChefWorkstation::WrappedError.new(e, conn)
      capture_exception_backtrace(wrapper)
      # Now that our housekeeping is done, allow user-facing handling/formatting
      # in `run` to execute by re-raising
      raise wrapper
    end

    def capture_exception_backtrace(e)
      UI::ErrorPrinter.write_backtrace(e, @argv)
    end

    def show_help
      UI::Terminal.output banner
      UI::Terminal.output ""
      UI::Terminal.output "FLAGS:"
      justify_length = 0
      options.each_value do |spec|
        justify_length = [justify_length, spec[:long].length + 4].max
      end
      options.sort.to_h.each_value do |spec|
        short = spec[:short] || "  "
        short = short[0, 2] # We only want the flag portion, not the capture portion (if present)
        if short == "  "
          short = "    "
        else
          short = "#{short}, "
        end
        flags = "#{short}#{spec[:long]}"
        UI::Terminal.output "    #{flags.ljust(justify_length)}    #{spec[:description]}"
      end
      UI::Terminal.output ""
      UI::Terminal.output "SUBCOMMANDS:"
      justify_length = ([7] + commands.map(&:length)).max + 4
      command_specs.sort.each do |name, spec|
        next if spec.hidden
        UI::Terminal.output "    #{"#{name}".ljust(justify_length)}#{spec.text.description}"
      end
      UI::Terminal.output "    #{"help".ljust(justify_length)}#{T.help}"
      UI::Terminal.output "    #{"version".ljust(justify_length)}#{T.version}"
      UI::Terminal.output ""
      UI::Terminal.output "ALIASES:"
      UI::Terminal.output "    converge    Alias for 'target converge'"
    end

    def commands_map
      ChefWorkstation.commands_map
    end

    def have_command?(name)
      commands_map.have_command?(name)
    end

    def commands
      commands_map.command_names
    end

    def command_specs
      commands_map.command_specs
    end

    class UnknownCommand < ErrorNoLogs
      def initialize(command_name, avail_commands)
        super("CHEFCLI001", command_name, avail_commands)
      end
    end
  end
end
