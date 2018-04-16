require "chef-workstation/telemetry"
require "chef-workstation/error"

module ChefWorkstation
  module Action
    # Derive new Actions from Action::Base
    # "connection" is a train connection that may be active and available
    #              based on
    # "config" is hash containing any options that your command may need
    #
    # Implement perform_action to perform whatever action your class is intended to do.
    # Run time will be captured via telemetry and categorized under ":action" with the
    # unqualified class name of your Action.
    class Base
      attr_reader :connection, :config

      def initialize(config = {})
        c = config.dup
        @connection = c.delete :connection
        # Remaining options are for child classes to make use of.
        @config = c
      end

      PATH_MAPPING = {
        chef_client: {
          windows: "cmd /c C:/opscode/chef/bin/chef-client",
          other: "/opt/chef/bin/chef-client",
        },
        read_chef_stacktrace: {
          windows: "type C:/chef/cache/chef-stacktrace.out",
          other: "cat /var/chef/cache/chef-stacktrace.out",
        },
        delete_chef_stacktrace: {
          windows: "del /f C:/chef/cache/chef-stacktrace.out",
          other: "rm -f /var/chef/cache/chef-stacktrace.out",
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
          f = @connection.platform.family
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
