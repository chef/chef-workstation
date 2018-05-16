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
require "chef-cli/config"
require "chef-cli/log"
require "chef-cli/telemeter"
require "chef-cli/telemeter/sender"
require "chef-cli/commands_map"
require "chef-cli/builtin_commands"
require "chef-cli/text"
require "chef-cli/error"
require "chef-cli/log"
require "chef-cli/ui/terminal"
require "chef-cli/ui/error_printer"
require "chef-dk/cli"

module ChefCLI
  class CLI
    T = ChefCLI::Text.cli
    RC_COMMAND_FAILED = 1
    RC_ERROR_HANDLING_FAILED = 64

    def initialize(argv)
      @argv = argv
      @rc = 0
      super()
    end

    def run
      setup_cli()
      # Start the process of submitting telemetry data from our previous run:
      # Note that we do not join on this thread - if it doesn't complete before
      # the command exectuion completes, then we'll pick up what's left in the next run.
      # We don't, under any circumstances, want to cause the user to encounter noticeable
      # delays when waiting for a command to complete because telemetry hasn't yet finished submitting.
      Thread.new() { ChefCLI::Telemeter::Sender.new().run }

      # Perform a timing and capture of the requested command. Individual
      # commands and actions may perform nested Telemeter.timed_*_capture or Telemeter.capture
      # calls in their operation, and they will be captured in the same telemetry session.
      # NOTE: We're not currently sending arguments to telemetry because we have not implemented
      #       pre-parsing of arguemtns to eliminate potentially sensitive data such as
      #       passwords in host name, or in ad-hoc converge properties.
      Telemeter.timed_run_capture([:redacted]) do
        begin
          perform_command()
        rescue WrappedError => e
          UI::ErrorPrinter.show_error(e)
          @rc = RC_COMMAND_FAILED
        rescue SystemExit => e
          @rc = e.status
        rescue Exception => e
          UI::ErrorPrinter.dump_unexpected_error(e)
          @rc = RC_ERROR_HANDLING_FAILED
        end
      end
    ensure
      Telemeter.commit
      exit @rc
    end

    def setup_cli
      # Enable CLI output via Terminal. This comes first because we want to supply
      # status output about reading and creating config files
      UI::Terminal.init($stdout)
      # Creates the tree we need under ~/.chef-workstation
      # based on config settings:
      Config.create_directory_tree

      # TODO because we have not loaded a command, we will always be using
      #      the default location at this step.
      if Config.using_default_location? && !Config.exist?
        setup_workstation
      end

      Config.load
      ChefCLI::Log.setup(Config.log.location, Config.log.level.to_sym)
      ChefCLI::Log.info("Initialized logger")
    end

    # This setup command is run if ".chef-workstation" is missing prior to
    # the run.  It will set up default configuration, generated an installation id
    # for telemetry, and report telemetry & config info to the operator.
    def setup_workstation
      require "securerandom"
      installation_id = SecureRandom.uuid
      File.write(Config.telemetry_installation_identifier_file, installation_id)
      UI::Terminal.output T.creating_config(Config.default_location)
      Config.create_default_config_file
      # Tell the user we're anonymously tracking, give brief opt-out
      # and a link to detailed information.
      UI::Terminal.output ""
      UI::Terminal.output T.telemetry_enabled(Config.default_location)
      UI::Terminal.output ""
    end

    def perform_command
      update_args_for_help
      update_args_for_version
      root_command, *leftover = @argv
      run_command!(root_command, leftover)
    rescue Exception => e
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
      elsif ChefDK::CLI.new(ARGV.clone).have_command?(command_name)
        ChefDK::CLI.new(ARGV.clone).run
      else
        ChefCLI::Log.error("Command not found: #{command_name}")
        raise UnknownCommand.new(command_name, visible_commands.join(" "))
      end
    end

    def handle_perform_error(e)
      id = e.respond_to?(:id) ? e.id : e.class.to_s
      message = e.respond_to?(:message) ? e.message : e.to_s
      Telemeter.capture(:error, exception: { id: id, message: message })
      wrapper = ChefCLI::StandardErrorResolver.wrap_exception(e)
      capture_exception_backtrace(wrapper)
      # Now that our housekeeping is done, allow user-facing handling/formatting
      # in `run` to execute by re-raising
      raise wrapper
    end

    def capture_exception_backtrace(e)
      UI::ErrorPrinter.write_backtrace(e, @argv)
    end

    def commands_map
      ChefCLI.commands_map
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
