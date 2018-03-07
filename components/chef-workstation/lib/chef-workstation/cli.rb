require "chef-workstation/config"
require "chef-workstation/version"
require "chef-workstation/command/show_config"
require "optparse"

module ChefWorkstation
  CLIOptions = Struct.new(:help, :version)

  class Cli
    attr_reader :cli_options

    def initialize(argv)
      @argv = argv
      @cli_options = CLIOptions.new

      @parser = OptionParser.new do |o|
        o.banner = banner
        o.on("-c", "--config PATH", "Location of config file to use. Defaults to #{ChefWorkstation::Config.default_location}") do |path|
          ChefWorkstation::Config.custom_location(path)
        end
        o.on_tail("-v", "--version", "Show current version of this tool.") do
          cli_options.version = true
        end
        o.on_tail("-h", "--help", "Show usage information for the chef command") do
          cli_options.help = true
        end
      end
    end

    def run
      parse_cli_options!
      initialize_config

      if @argv[0..1] == %w{config show}
        Command::ShowConfig.new.run
      else
        puts "Version #{ChefWorkstation::VERSION}" if cli_options.version
        puts @parser if cli_options.help
        if !cli_options.version && !cli_options.help
          puts short_banner
        end
      end
    end

    def parse_cli_options!
      @parser.parse!(@argv)
      # Another way to get help
      cli_options.help = true if @argv.include?("help")
      nil
    end

    def short_banner
      "Usage:  chef COMMAND [options...]"
    end

    def banner
      <<EOM
#{short_banner}

Congratulations! You are using chef: your gateway
to managing everything from a single node to an entire Chef
infrastructure.

Required Arguments:
    COMMAND - the command to execute, one of:
       help - show command help

Flags:
EOM
    end

    def initialize_config
      if ChefWorkstation::Config.using_default_location? && !ChefWorkstation::Config.exist?
        puts "Creating config file in #{ChefWorkstation::Config.default_location}"
        ChefWorkstation::Config.create_default_config_file
      end
      ChefWorkstation::Config.load
    end
  end
end
