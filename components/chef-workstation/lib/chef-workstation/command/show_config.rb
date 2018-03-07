# TODO eventually when we have more commands we will want to do something closer to Shake Shack where we have a commands map and all the commands inherit from a base class. But thats too much scope creep for the current PR
require "awesome_print"
require "chef-workstation/config"

module ChefWorkstation
  module Command
    class ShowConfig

      def run
        d = Config.using_default_location? ? "default ": ""
        puts "Config loaded from #{d}path #{Config.location}"
        ap Config.to_hash, {
          indent: 2,
          plain: true,
          ruby19_syntax: true,
        }
      end

    end
  end
end
