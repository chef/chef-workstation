
require "chef-workstation/version"
require "optparse"

module ChefWorkstation
  CLIConfig = Struct.new(:help, :version)

  class Cli
    attr_reader :config

    def initialize(argv)
      @argv = argv
      @config = CLIConfig.new

      @parser = OptionParser.new do |o|
        o.banner = banner
        # o.on(...)
        # ...
        o.on_tail("-v", "--version", "Show current version of this tool.") do
          config.version = true
        end
        o.on_tail("-h", "--help", "Show usage information for the chef command") do
          config.help = true
        end
      end
    end

    def run
      parse_cli_params!

      puts "Version #{ChefWorkstation::VERSION}" if config.version
      puts @parser if config.help
      if !config.version && !config.help
        puts short_banner
      end
    end

    def parse_cli_params!
      @parser.parse!(@argv)
      # Another way to get help
      config.help = true if @argv.include?("help")
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
infrastructure

Required Arguments:
    COMMAND - the command to execute, one of:
       help - show command help

Flags:
EOM
    end
  end
end
