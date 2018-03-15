require "chef-workstation/action/base"

module ChefWorkstation::Action
  class ConvergeTarget < Base
    def perform_action
      connection.run_command("/opt/chef/bin/chef-client")
    end
  end
end


