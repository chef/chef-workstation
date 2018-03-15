require "mixlib/log"

module ChefWorkstation
  class Log
    extend Mixlib::Log

    def self.setup(location, log_level = "warn")
      if location.is_a?(String)
        if location.casecmp("stdout") == 0
          location = $stdout
        else
          location = File.open(location, "w+")
        end
      end
      init(location)
    end

  end
end
