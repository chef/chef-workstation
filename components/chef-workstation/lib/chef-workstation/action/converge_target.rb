require "chef-workstation/action/base"
require "chef-workstation/text"

module ChefWorkstation::Action
  class ConvergeTarget < Base
    T = ChefWorkstation::Text.actions.converge_target

    attr_reader :resource_type, :resource_name, :attributes
    def initialize(config)
      super(config)
      @resource_type = @config.delete :resource_type
      @resource_name = @config.delete :resource_name
      @attributes = @config.delete(:attributes) || []
    end

    def perform_action
      apply_args = create_apply_args

      full_rs_name = "#{resource_type}[#{resource_name}]"
      ChefWorkstation::Log.debug("Converging #{full_rs_name} with attributes #{attributes}")

      c = connection.run_command("#{chef_apply} --no-color -e #{apply_args}")
      if c.exit_status == 0
        ChefWorkstation::Log.debug(c.stdout)
        reporter.success(T.success(full_rs_name))
      else
        reporter.error(T.error(ChefWorkstation::Log.location))
        # Ideally we will eventually write a custom handler to package up data we care
        # about - https://docs.chef.io/handlers.html
        c = connection.run_command(read_chef_stacktrace)
        if c.exit_status == 0
          ChefWorkstation::Log.error("Remote chef-apply error follows:")
          ChefWorkstation::Log.error("\n    " + c.stdout.split("\n").join("\n    "))
          # We need to delete the stacktrace after copying it over. Otherwise if we get a
          # remote failure that does not write a chef stacktrace its possible to get an old
          # stale stacktrace.
          connection.run_command(delete_chef_stacktrace)
        else
          ChefWorkstation::Log.error("Could not read remote stacktrace:")
          ChefWorkstation::Log.error("stdout: #{c.stdout}")
          ChefWorkstation::Log.error("stderr: #{c.stderr}")
        end
        raise RemoteChefClientRunFailed.new
      end
    end

    def create_apply_args
      apply_args = "\"#{resource_type} '#{resource_name}'"
      # lets format the attributes into the correct syntax Chef expects
      unless attributes.empty?
        apply_args += " do; "
        attributes.each do |k, v|
          v = "'#{v}'" if v.is_a? String
          apply_args += "#{k} #{v}; "
        end
        apply_args += "end"
      end
      apply_args += "\""
    end

    class RemoteChefClientRunFailed < ChefWorkstation::Error
      def initialize(); super("CHEFCCR001"); end
    end
  end
end
