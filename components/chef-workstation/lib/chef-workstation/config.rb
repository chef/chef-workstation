require "mixlib/config"

module ChefWorkstation
  class Config
    extend Mixlib::Config

    config_strict_mode true

    # When working on chef-workstation itself,
    # developers should set telemetry.dev to true
    # in their local configuration to ensure that dev usage
    # doesn't skew customer telemetry.
    config_context :telemetry do
      default(:dev, false)
    end

    class << self
      @custom_location = nil

      def custom_location(path)
        @custom_location = path
        raise "No config file located at #{path}" unless exist?
      end

      def default_location
        Pathname.new("~/.chef-workstation/config.toml").expand_path.to_s
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

      def create_default_config_file
        FileUtils.mkdir_p(File.dirname(default_location))
        FileUtils.touch(default_location)
      end

      def reset
        @custom_location = nil
        super
      end
    end
  end
end
