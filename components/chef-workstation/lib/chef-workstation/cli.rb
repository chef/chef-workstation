require "chef-workstation/config"
require "chef-workstation/version"
require "chef-workstation/telemetry"
require "chef-workstation/command/show_config"
require "optparse"
require "chef-workstation/text"

module ChefWorkstation
  CLIOptions = Struct.new(:help, :version)

  class Cli
    attr_reader :cli_options

    def initialize(argv)
      @argv = argv
      @cli_options = CLIOptions.new
      # Load our canned texts
      Text.load

      @parser = OptionParser.new do |o|
        o.banner = Text.cli.banner
        o.on("-c", "--config PATH", Text.cli.config(ChefWorkstation::Config.default_location)) do |path|
          ChefWorkstation::Config.custom_location(path)
        end
        o.on_tail("-v", "--version", Text.cli.version) do
          cli_options.version = true
        end
        o.on_tail("-h", "--help", Text.cli.option_info.help) do
          cli_options.help = true
        end
      end
    end

    def run
      parse_cli_options!
      initialize_config
      # Perform a timing and capture of the requested command. Individual
      # commands and components may perform nested Telemetry.timed_capture or Telemetry.capture
      # calls in their operation.
      Telemetry.timed_capture(:run, command: @command,
                                    sub: @subcommand, args: @argv,
                                    opts: @cli_options.to_h) { perform_command() }
    ensure
      # Ship off everything captured both above
      # and within the individual commands.
      Telemetry.send!
    end

    def parse_cli_options!
      @parser.parse!(@argv)
      # Another way to get help
      # TODO - this should e handled as a subcommand,
      # so that we don't display standard help if someone does "chef converge help"
      cli_options.help = true if @argv.include?("help")
      @command = @argv.shift # Primary command to execute, eg 'help' or 'show'
      if @argv[0] != "help"
        @subcommand = @argv.shift
      end

      nil
    end

    def initialize_config
      if ChefWorkstation::Config.using_default_location? && !ChefWorkstation::Config.exist?
        puts Text.cli.creating_config(ChefWorkstation::Config.default_location)
        ChefWorkstation::Config.create_default_config_file
      end
      ChefWorkstation::Config.load
    end

    def perform_command
      if @argv[0..1] == %w{config show}
        Command::ShowConfig.new.run
      else
        show_version if cli_options.version
        show_help if cli_options.help
        if !cli_options.version && !cli_options.help
          show_short_banner
        end
      end
    rescue => e
      id = e.respond_to?(:id) ? e.id : e.class.to_s
      Telemetry.capture(:error, exception: { id: id, message: e.message })
      raise
    end

    def show_version
      puts Text.cli.version_msg(ChefWorkstation::VERSION) if cli_options.version
    end

    def show_help
      puts @parser
    end

    def show_short_banner
      puts Text.cli.short_banner
    end
  end
end
