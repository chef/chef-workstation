#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "chef-run/action/base"
require "chef-run/text"
require "pathname"
require "tempfile"
require "chef/util/path_helper"

module ChefRun::Action
  class ConvergeTarget < Base

    def perform_action
      local_policy_path = config.delete :local_policy_path
      remote_tmp = target_host.run_command!(mktemp, true)
      remote_dir_path = escape_windows_path(remote_tmp.stdout.strip)
      remote_policy_path = create_remote_policy(local_policy_path, remote_dir_path)
      remote_config_path = create_remote_config(remote_dir_path)
      create_remote_handler(remote_dir_path)
      upload_trusted_certs(remote_dir_path)

      notify(:running_chef)
      cmd_str = run_chef(remote_dir_path,
                         File.basename(remote_config_path),
                         File.basename(remote_policy_path))
      c = target_host.run_command(cmd_str)
      target_host.run_command!("#{delete_folder} #{remote_dir_path}")
      if c.exit_status == 0
        ChefRun::Log.debug(c.stdout)
        notify(:success)
      elsif c.exit_status == 35
        notify(:reboot)
      else
        notify(:converge_error)
        handle_ccr_error()
      end
    end

    def create_remote_policy(local_policy_path, remote_dir_path)
      remote_policy_path = File.join(remote_dir_path, File.basename(local_policy_path))
      notify(:creating_remote_policy)
      begin
        target_host.upload_file(local_policy_path, remote_policy_path)
      rescue RuntimeError => e
        ChefRun::Log.error(e)
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
        reporter = ChefRun::Reporter.new
        report_handlers << reporter
        exception_handlers << reporter
      EOM

      # Maybe add data collector endpoint.
      dc = ChefRun::Config.data_collector
      if !dc.url.nil? && !dc.token.nil?
        workstation_rb << <<~EOM
          data_collector.server_url "#{dc.url}"
          data_collector.token "#{dc.token}"
          data_collector.mode :solo
          data_collector.organization "Chef Workstation"
        EOM
      end

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

    def upload_trusted_certs(dir)
      local_tcd = Chef::Util::PathHelper.escape_glob_dir(ChefRun::Config.chef.trusted_certs_dir)
      certs = Dir.glob(File.join(local_tcd, "*.{crt,pem}"))
      return if certs.empty?
      notify(:uploading_trusted_certs)
      remote_tcd = "#{dir}/trusted_certs"
      # We create the trusted_certs dir with the connection user (instead of the root
      # user it would get as default since we run in sudo mode) because the `upload_file`
      # uploads as the connection user. Without this upload_file would fail because
      # it tries to write to a root-owned folder.
      target_host.run_command("#{mkdir} #{remote_tcd}", true)
      certs.each do |cert_file|
        target_host.upload_file(cert_file, "#{remote_tcd}/#{File.basename(cert_file)}")
      end
    end

    def handle_ccr_error
      require "chef-run/errors/ccr_failure_mapper"
      mapper_opts = {}
      c = target_host.run_command(read_chef_report)
      if c.exit_status == 0
        report = JSON.parse(c.stdout)
        # We need to delete the stacktrace after copying it over. Otherwise if we get a
        # remote failure that does not write a chef stacktrace its possible to get an old
        # stale stacktrace.
        target_host.run_command!(delete_chef_report)
        ChefRun::Log.error("Remote chef-client error follows:")
        ChefRun::Log.error(report["exception"])
      else
        report = {}
        ChefRun::Log.error("Could not read remote report:")
        ChefRun::Log.error("stdout: #{c.stdout}")
        ChefRun::Log.error("stderr: #{c.stderr}")
        mapper_opts[:stdout] = c.stdout
        mapper_opts[:stdrerr] = c.stderr
      end
      mapper = ChefRun::Errors::CCRFailureMapper.new(report["exception"], mapper_opts)
      mapper.raise_mapped_exception!
    end

    class ConfigUploadFailed < ChefRun::Error
      def initialize(); super("CHEFUPL003"); end
    end

    class HandlerUploadFailed < ChefRun::Error
      def initialize(); super("CHEFUPL004"); end
    end

    class PolicyUploadFailed < ChefRun::Error
      def initialize(); super("CHEFUPL005"); end
    end
  end
end
