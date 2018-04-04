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
        reporter.error(T.error)
        handle_ccr_error()
      end
    end

    def handle_ccr_error
      require "chef-workstation/errors/ccr_failure_mapper"
      mapper_opts = { resource: resource_type, resource_name: resource_name }
      c = connection.run_command(read_chef_stacktrace)
      if c.exit_status == 0
        lines = c.stdout.split("\n")
        # We need to delete the stacktrace after copying it over. Otherwise if we get a
        # remote failure that does not write a chef stacktrace its possible to get an old
        # stale stacktrace.
        connection.run_command(delete_chef_stacktrace)
        ChefWorkstation::Log.error("Remote chef-apply error follows:")
        ChefWorkstation::Log.error("\n    " + lines.join("\n    "))
      else
        lines = []
        ChefWorkstation::Log.error("Could not read remote stacktrace:")
        ChefWorkstation::Log.error("stdout: #{c.stdout}")
        ChefWorkstation::Log.error("stderr: #{c.stderr}")
        mapper_opts[:stdout] = c.stdout
        mapper_opts[:stdrerr] = c.stderr
      end
      mapper = ChefWorkstation::Errors::CCRFailureMapper.new(lines, mapper_opts)
      mapper.raise_mapped_exception!
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

  end
end
