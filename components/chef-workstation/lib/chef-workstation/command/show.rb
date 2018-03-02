# TODO eventually when we have more commands we will want to do something closer to Shake Shack where we have a commands map and all the commands inherit from a base class. But thats too much scope creep for the current PR
require "pp"
require "chef-workstation/config"

module ChefWorkstation
  module Command
    class Show

      def run
        puts "Currently loaded config:"
        pp Config.to_hash
      end

    end
  end
end
