require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/version"
require "chef-workstation/telemetry"
require "chef-workstation/commands_map"
require "chef-workstation/builtin_commands"
require "chef-workstation/text"
require "chef-workstation/ui/terminal"
require "mixlib/cli"

module ChefWorkstation
  class CLI
    include Mixlib::CLI

    banner Text.cli.banner

    option :version,
      :long         => "--version",
      :description  => Text.cli.version,
      :boolean      => true

    option :help,
      :short        => "-h",
      :long         => "--help",
      :description  => Text.cli.help,
      :boolean      => true

    option :config_path,
      :short        => "-c PATH",
      :long         => "--config PATH",
      :description  => Text.cli.config(ChefWorkstation::Config.default_location),
      :default      => ChefWorkstation::Config.default_location,
      :proc         => Proc.new { |path| ChefWorkstation::Config.custom_location(path) }

    def initialize(argv)
      @argv = argv
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
    ensure
      Telemetry.send!
    end

    def init
      # Initialize the config and load it
      if ChefWorkstation::Config.using_default_location? && !ChefWorkstation::Config.exist?
        puts Text.cli.creating_config(ChefWorkstation::Config.default_location)
        ChefWorkstation::Config.create_default_config_file
      end
      ChefWorkstation::Config.load

      # Ensure our logger is setup
      l = ChefWorkstation::Config.log
      ChefWorkstation::Log.setup(l.location)
      Log.level = l.level.to_sym
      ChefWorkstation::Log.info("Initialized logger")

      # Ensure the CLI outputter is setup
      UI::Terminal.init
    end

    def perform_command
      command_name, *command_params = @argv
      if command_name.nil? || %w{help -h --help}.include?(command_name.downcase)
        if command_params.empty?
          puts Text.cli.print_version(ChefWorkstation::VERSION)
          show_help
          return
        else
          # They are trying to get help text on something else - like `chef help converge`
          # We pass down the help flag to the actual class they are trying to get help text on
          command_name = command_params.shift
          command_params << "-h"
        end
      elsif %w{version --version}.include?(command_name.downcase)
        puts ChefWorkstation::VERSION
        return
      end
      if have_command?(command_name)
        cmd, command_params = commands_map.instantiate(command_name, command_params)
        exit_code = cmd.run_with_default_options(command_params)
        exit exit_code
      else
        puts "Unknown command '#{command_name}'."
        show_help
        exit 1
      end
    rescue => e
      id = e.respond_to?(:id) ? e.id : e.class.to_s
      Telemetry.capture(:error, exception: { id: id, message: e.message })
      raise
    end

    def show_help
      puts banner
      puts ""
      puts "FLAGS:"
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
        puts "    #{flags.ljust(justify_length)}    #{spec[:description]}"
      end
      puts ""
      puts "SUBCOMMANDS:"
      justify_length = ([7] + commands.map(&:length)).max + 4
      command_specs.sort.each do |name, spec|
        next if spec.hidden
        puts "    #{"#{name}".ljust(justify_length)}#{spec.text.description}"
      end
      puts "    #{"help".ljust(justify_length)}#{Text.cli.help}"
      puts "    #{"version".ljust(justify_length)}#{Text.cli.version}"
      puts ""
      puts "ALIASES:"
      puts "    TODO autopopulate"
      puts "    converge    Alias for 'target converge'"
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
  end
end
