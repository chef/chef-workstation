require "chef-workstation/action/base"
require "chef-workstation/text"

module ChefWorkstation::Action
  class ConvergeTarget < Base
    attr_reader :resource_type, :resource_name
    def initialize(config)
      super(config)
      @resource_type = @config.delete :resource_type
      @resource_name = @config.delete :resource_name
    end

    def perform_action
      apply_args = "\"#{@resource_type} '#{@resource_name}'\""
      c = connection.run_command("/opt/chef/bin/chef-apply -e #{apply_args}")
      if c.exit_status == 0
        ChefWorkstation::Log.debug(c.stdout)
        full_rs_name = "#{resource_type}[#{resource_name}]"
        reporter.success("Successfully converged #{full_rs_name}!")
      else
        reporter.error("Failed to converge remote machine. See detailed log")
        ChefWorkstation::Log.error("Remote chef-apply error follows: ")
        # Using Log for each line so that we can keep consistent formatting -
        # undecorated lines are the bane of automated log parsing...
        # Indent the output line for readability
        c.stdout.split("\n").each { |line| ChefWorkstation::Log.error("    #{line}") }
        # TODO raise an error here? How do we communicate this failure up?
      end
    end
  end
end
