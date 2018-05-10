require "chef-workstation/action/base"
require "chef-workstation/text"
require "pathname"
require "tempfile"
require "chef-dk/ui"
require "chef-dk/policyfile_services/export_repo"
require "chef-dk/policyfile_services/install"

module ChefWorkstation::Action
  class ConvergeTarget < Base

    def perform_action
      local_cookbook = config.delete :local_cookbook
      remote_tmp = target_host.run_command!(mktemp)
      remote_dir_path = escape_windows_path(remote_tmp.stdout.strip)
      notify(:creating_remote_policy)
      remote_policy_path = create_remote_policy(local_cookbook, remote_dir_path)
      remote_config_path = create_remote_config(remote_dir_path)
      create_remote_handler(remote_dir_path)

      notify(:running_chef)
      c = target_host.run_command(run_chef(
        remote_dir_path,
        File.basename(remote_config_path),
        File.basename(remote_policy_path)
      ))

      target_host.run_command!("#{delete_folder} #{remote_dir_path}")
      if c.exit_status == 0
        ChefWorkstation::Log.debug(c.stdout)
        notify(:success)
      else
        notify(:converge_error)
        handle_ccr_error()
      end
    end

    def create_remote_policy(local_cookbook, remote_dir_path)
      local_policy_path = generate_policy(local_cookbook)
      remote_policy_path = File.join(remote_dir_path, File.basename(local_policy_path))
      begin
        target_host.upload_file(local_policy_path, remote_policy_path)
      rescue RuntimeError
        raise PolicyUploadFailed.new()
      end
      remote_policy_path
    end

    def create_remote_config(dir)
      remote_config_path = File.join(dir, "workstation.rb")

      workstation_rb = <<~EOM
        local_mode true
        color false
        cache_path "#{cache_path}"
        chef_repo_path "#{cache_path}"
        require_relative "reporter"
        reporter = ChefWorkstation::Reporter.new
        report_handlers << reporter
        exception_handlers << reporter
      EOM

      begin
        config_file = Tempfile.new
        config_file.write(workstation_rb)
        config_file.close
        target_host.upload_file(config_file.path, remote_config_path)
      rescue RuntimeError
        raise ConfigUploadFailed.new()
      ensure
        config_file.unlink
      end
      remote_config_path
    end

    def create_remote_handler(dir)
      remote_handler_path = File.join(dir, "reporter.rb")
      begin
        handler_file = Tempfile.new
        handler_file.write(File.read(File.join(__dir__, "reporter.rb")))
        handler_file.close
        target_host.upload_file(handler_file.path, remote_handler_path)
      rescue RuntimeError
        raise HandlerUploadFailed.new()
      ensure
        handler_file.unlink
      end
      remote_handler_path
    end

    def generate_policy(local_cookbook)
      ChefDK::PolicyfileServices::Install.new(ui: ChefDK::UI.null(),
                                              root_dir: local_cookbook.path).run
      lock_path = File.join(local_cookbook.path, "Policyfile.lock.json")
      es = ChefDK::PolicyfileServices::ExportRepo.new(policyfile: lock_path,
                                                      root_dir: local_cookbook.path,
                                                      export_dir: File.join(local_cookbook.path, "export"),
                                                      archive: true,
                                                      force: true)
      es.run
      es.archive_file_location
    end

    def handle_ccr_error
      require "chef-workstation/errors/ccr_failure_mapper"
      mapper_opts = {}
      c = target_host.run_command(read_chef_report)
      if c.exit_status == 0
        report = JSON.parse(c.stdout)
        # We need to delete the stacktrace after copying it over. Otherwise if we get a
        # remote failure that does not write a chef stacktrace its possible to get an old
        # stale stacktrace.
        target_host.run_command!(delete_chef_report)
        ChefWorkstation::Log.error("Remote chef-client error follows:")
        ChefWorkstation::Log.error(report["exception"])
      else
        report = {}
        ChefWorkstation::Log.error("Could not read remote report:")
        ChefWorkstation::Log.error("stdout: #{c.stdout}")
        ChefWorkstation::Log.error("stderr: #{c.stderr}")
        mapper_opts[:stdout] = c.stdout
        mapper_opts[:stdrerr] = c.stderr
      end
      mapper = ChefWorkstation::Errors::CCRFailureMapper.new(report["exception"], mapper_opts)
      mapper.raise_mapped_exception!
    end

    class ConfigUploadFailed < ChefWorkstation::Error
      def initialize(); super("CHEFUPL003"); end
    end

    class HandlerUploadFailed < ChefWorkstation::Error
      def initialize(); super("CHEFUPL004"); end
    end

    class PolicyUploadFailed < ChefWorkstation::Error
      def initialize(); super("CHEFUPL005"); end
    end
  end
end
