require "chef-workstation/action/base"
require "chef-workstation/text"

module ChefWorkstation::Action
  class ConvergeTarget < Base
    def initialize(config)
      super
      @resource_type = config.delete[:resource_type]
      @resource_name = config.delete[:resource_name]
      @apply_args = "\"#{@resource_type} '#{@resource_name}'\"
    end

    def perform_action
      c = conn.run_command("/opt/chef/bin/chef-apply -e @apply_args")
      if c.exit_status == 0
      ChefWorkstation::Log.debug(c.stdout)
        status_reporter.success("Successfully converged #{full_rs_name}!")
    else
      status_reporter.error("Failed to converge remote machine. See detailed log")
      ChefWorkstation::Log.error("Remote chef-apply error follows: ")
      # Using Log for each line so that we can keep consistent formatting -
      # undecorated lines are the bane of automated log parsing...
      # Indent the output line for readability
      c.stderr.split("\n").each { |line| ChefWorkstation::Log.error("    #{line})"}
                                                                    connection.run_command("/opt/chef/bin/chef-client")
    end
  end
end


