require "chef-workstation/action/base"
require "chef-workstation/text"
require "ostruct"

module ChefWorkstation::Action
  class ConvergeTarget < Base
    T = ChefWorkstation::Text.actions.converge_target

    attr_reader :resource_type, :resource_name
    def initialize(config)
      super(config)
      @resource_type = @config.delete :resource_type
      @resource_name = @config.delete :resource_name
    end

    def perform_action
      apply_args = "\"#{@resource_type} '#{@resource_name}'\""
      c = connection.run_command("#{chef_apply} --no-color -e #{apply_args}")
      if c.exit_status == 0
        ChefWorkstation::Log.debug(c.stdout)
        full_rs_name = "#{resource_type}[#{resource_name}]"
        reporter.success(T.success(full_rs_name))
      else
        reporter.error(T.error(ChefWorkstation::Log.location))
        # Ideally we will eventually write a custom handler to package up data we care
        # about - https://docs.chef.io/handlers.html
        c = connection.run_command(read_chef_stacktrace)
        if c.exit_status == 0
          ChefWorkstation::Log.error("Remote chef-apply error follows:")
          ChefWorkstation::Log.error("\n    " + c.stdout.split("\n").join("\n    "))
        else
          ChefWorkstation::Log.error("Could not read remote stacktrace:")
          ChefWorkstation::Log.error("stdout: #{c.stdout}")
          ChefWorkstation::Log.error("stderr: #{c.stderr}")
        end
      end
    end
  end
end
