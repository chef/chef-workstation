require "mixlib/config"
require "fileutils"
require "pathname"

module ChefWorkstation
  class Config
    WS_BASE_PATH = File.join(Dir.home, ".chef-workstation/")

    extend Mixlib::Config

    config_strict_mode true

    # When working on chef-workstation itself,
    # developers should set telemetry.dev to true
    # in their local configuration to ensure that dev usage
    # doesn't skew customer telemetry.
    config_context :telemetry do
      default(:dev, false)
    end

    config_context :log do
      default(:level, "warn")
      default(:location, File.join(WS_BASE_PATH, "logs/default.log"))
    end

    config_context :cache do
      default(:path, File.join(WS_BASE_PATH, "cache"))
    end
    config_context :dev do
      default(:spinner, "TTY::Spinner")
    end

    class << self
      @custom_location = nil

      def custom_location(path)
        @custom_location = path
        raise "No config file located at #{path}" unless exist?
      end

      def default_location
        File.join(WS_BASE_PATH, "config.toml")
      end

      def stack_trace_path
        File.join(File.dirname(log.location), "stack-trace.log")
      end

      def using_default_location?
        @custom_location.nil?
      end

      def location
        using_default_location? ? default_location : @custom_location
      end

      def load
        from_file(location)
      end

      def exist?
        File.exist? location
      end

      def create_directory_tree
        FileUtils.mkdir_p(File.dirname(default_location))
        FileUtils.mkdir_p(File.dirname(stack_trace_path))
      end

      def create_default_config_file
        FileUtils.touch(default_location)
      end

      def reset
        @custom_location = nil
        super
      end
    end
  end
end
