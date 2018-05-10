require "mixlib/log"

module ChefCLI
  class Log
    extend Mixlib::Log

    def self.setup(location, log_level)
      @location = location
      if location.is_a?(String)
        if location.casecmp("stdout") == 0
          location = $stdout
        else
          location = File.open(location, "w+")
        end
      end
      init(location)
      Log.level = log_level
    end

    def self.location
      @location
    end

  end
end
