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
require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/telemetry"
require "chef-workstation/commands_map"
require "chef-workstation/builtin_commands"
require "chef-workstation/text"
require "chef-workstation/error"
require "chef-workstation/log"
require "chef-workstation/ui/terminal"
require "chef-workstation/ui/error_printer"

module ChefWorkstation
  class CLI
    T = ChefWorkstation::Text.cli
    RC_COMMAND_FAILED = 1
    RC_ERROR_HANDLING_FAILED = 64

    def initialize(argv)
      @argv = argv
      @rc = 0
      super()
    end

    def run
      # Perform a timing and capture of the requested command. Individual
      # commands and components may perform nested Telemetry.timed_capture or Telemetry.capture
      # calls in their operation.
      Telemetry.timed_capture(:run, args: @argv) do
        setup_cli()
        perform_command()
      end

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

    def setup_cli
      #TODO - how to handle if we don't eval the config file option,
      #and they specify 'chef -c blah invalid-command'
      # Enable CLI output via Terminal. This comes first because we want to supply
      # status output about reading and creating config files
      UI::Terminal.init($stdout)
      # Creates the tree we need under ~/.chef-workstation
      # based on config settings:
      Config.create_directory_tree
      if Config.using_default_location? && !Config.exist?
        UI::Terminal.output T.creating_config(Config.default_location)
        Config.create_default_config_file
      end
      Config.load
      ChefWorkstation::Log.setup(Config.log.location, Config.log.level.to_sym)
      ChefWorkstation::Log.info("Initialized logger")
    end

    def perform_command
      update_args_for_help
      update_args_for_version
      root_command, *leftover = @argv

      run_command!(root_command, leftover)
    rescue => e
      handle_perform_error(e)
    end

    # This converts any use of version as a flag into a 'version' command.
    # placed as the first command.
    def update_args_for_version
      version_included = false
      @argv.delete_if do |item|
        if item =~ /^--version|-v/
          version_included = true
          true
        else
          false
        end
      end
      @argv.unshift "version" if version_included
    end

    # This converts any use of help as a command into a '--help' flag
    # This lets us present it as a command, but rely on the command we want help for
    # to handle providing that help.
    def update_args_for_help
      if @argv.empty?
        @argv << "--help"
        return
      end

      # Special case for prefixed --help/-h: we have to move it to the end so that
      # we don't consider '-h' to be the command we're trying to load.
      if %w{help -h --help}.include?(@argv[0].downcase)
        # Make help command the last option to the specified command (if any)
        # so that it's handled by the command that is being asked about.
        @argv.shift
        @argv << "--help"
      elsif @argv.last.casecmp("help") == 0
        @argv.pop
        @argv.push "--help"
      else
        @argv = @argv.map { |arg| arg == "help" ? "--help" : arg }
      end
    end

    def run_command!(command_name, command_params)
      # TODO 2018-04-20  we still have a general misbehavior when we
      #                  do 'chef --any-flag any-command' because it will always pass
      #                  the flag as the command name. We'll want to apply a more general
      #                  solution, being mindful that some flags do require parameters - something
      #                  we can't see at this level currently.
      if command_name.nil? || %w{-h --help help}.include?(command_name.downcase)
        # hidden-root represents the base "Chef" command which knows how to report
        # help for that top-level command.  IDeally we'll return to this
        # and make it represent the actual 'chef' command.
        command_name = "hidden-root"
      end

      if have_command?(command_name)
        @cmd, command_params = commands_map.instantiate(command_name, command_params)
        @cmd.run_with_default_options(command_params)
      else
        ChefWorkstation::Log.error("Command not found: #{command_name}")
        raise UnknownCommand.new(command_name, visible_commands.join(" "))
      end
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

    def commands_map
      ChefWorkstation.commands_map
    end

    def have_command?(name)
      commands_map.have_command_or_alias?(name)
    end

    def visible_commands
      commands_map.command_names(false)
    end

    def available_commands
      commands_map.command_names(true)
    end

    def command_aliases
      commands_map.alias_specs
    end

    def command_specs
      commands_map.command_specs
    end

    class UnknownCommand < ErrorNoLogs
      def initialize(command_name, avail_commands)
        super("CHEFCLI001", command_name, avail_commands)
        @decorate = false
      end
    end
  end
end
