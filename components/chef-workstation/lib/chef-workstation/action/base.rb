require "chef-workstation/telemetry"
require "chef-workstation/error"

module ChefWorkstation
  module Action
    # Derive new Actions from Action::Base
    # "target_host" is a TargetHost that the action is being applied to. May be nil
    #               if the action does not require a target.
    # "config" is hash containing any options that your command may need
    #
    # Implement perform_action to perform whatever action your class is intended to do.
    # Run time will be captured via telemetry and categorized under ":action" with the
    # unqualified class name of your Action.
    class Base
      attr_reader :target_host, :config

      def initialize(config = {})
        c = config.dup
        @target_host = c.delete :target_host
        # Remaining options are for child classes to make use of.
        @config = c
      end

      run_report = "$env:APPDATA/chef-workstation/cache/run-report.json"
      PATH_MAPPING = {
        chef_client: {
          windows: "cmd /c C:/opscode/chef/bin/chef-client",
          other: "/opt/chef/bin/chef-client",
        },
        cache_path: {
          windows: '#{ENV[\'APPDATA\']}/chef-workstation',
          other: "/var/chef-workstation",
        },
        read_chef_report: {
          windows: "type #{run_report}",
          other: "cat /var/chef-workstation/cache/run-report.json",
        },
        delete_chef_report: {
          windows: "If (Test-Path #{run_report}){ Remove-Item -Force -Path #{run_report} }",
          other: "rm -f /var/chef-workstation/cache/run-report.json",
        },
        tempdir: {
          windows: "%TEMP%",
          other: "$TMPDIR",
        },
        # TODO this is duplicating some stuff in the install_chef folder
        # TODO maybe we start to break these out into actual functions, so
        # we don't have to try and make really long one-liners
        mktemp: {
          windows: "$parent = [System.IO.Path]::GetTempPath(); [string] $name = [System.Guid]::NewGuid(); $tmp = New-Item -ItemType Directory -Path (Join-Path $parent $name); $tmp.FullName",
          other: "bash -c 'd=$(mktemp -d -p${TMPDIR:-/tmp} chef_XXXXXX); chmod 777 $d; echo $d'"
        },
        delete_folder: {
          windows: "Remove-Item -Recurse -Force –Path",
          other: "rm -rf",
        }
      }

      PATH_MAPPING.keys.each do |m|
        define_method(m) { PATH_MAPPING[m][family] }
      end

      # Chef will try 'downloading' the policy from the internet unless we pass it a valid, local file
      # in the working directory. By pointing it at a local file it will just copy it instead of trying
      # to download it.
      def run_chef(working_dir, config, policy)
        case family
        when :windows
          "Set-Location -Path #{working_dir}; " +
            "chef-client -z --config #{config} --recipe-url #{policy}; " +
            # We have to working dir so we don't hold a lock on it, which allows us to delete this tempdir later
            "Set-Location C:/; " +
            "exit $LASTEXITCODE"
        else
          # cd is shell a builtin, so much call bash. This also means all commands are executed
          # with sudo (as long as we are hardcoding our sudo use)
          "bash -c 'cd #{working_dir}; chef-client -z --config #{config} --recipe-url #{policy}'"
        end
      end

      # Trying to perform File or Pathname operations on a Windows path with '\'
      # characters in it fails. So lets convert them to '/' which these libraries
      # handle better.
      def escape_windows_path(p)
        if family == :windows
          p = p.tr("\\", "/")
        end
        p
      end

      def run(&block)
        @notification_handler = block
        Telemetry.timed_capture(:action, name: self.class.name.split("::").last) do
          perform_action
        end
      end

      def perform_action
        raise NotImplemented
      end

      def notify(action, *args)
        return if @notification_handler.nil?
        ChefWorkstation::Log.debug("[#{self.class.name}] Action: #{action}, Action Data: #{args}")
        @notification_handler.call(action, args) if @notification_handler
      end

      private

      def family
        @family ||= begin
          f = target_host.platform.family
          if f == "windows"
            :windows
          else
            :other
          end
        end
      end
    end
  end
end
