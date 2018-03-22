require "chef-workstation/telemetry"
require "chef-workstation/error"

module ChefWorkstation
  module Action
    # Derive new Actions from Action::Base
    # "connection" is a train connection that may be active and available
    #              based on
    # "reporter" is an interface to the UI that supports 'status', 'success', and 'failure'.
    # "config" is hash containing any options that your command may need
    #
    # Implement perform_action to perform whatever action your class is intended to do.
    # Run time will be captured via telemetry and categorized under ":action" with the
    # unqualified class name of your Action.
    class Base
      attr_reader :connection, :config
      attr_accessor :reporter

      def initialize(config = {})
        c = config.dup
        @reporter = c.delete :reporter
        @connection = c.delete :connection
        # Remaining options are for child classes to make use of.
        @config = c
      end

      PATH_MAPPING = {
        chef_apply: {
          windows: "cmd /c C:/opscode/chef/bin/chef-apply",
          other: "/opt/chef/bin/chef-apply",
        },
        read_chef_stacktrace: {
          windows: "type C:/chef/cache/chef-stacktrace.out",
          other: "cat /var/chef/cache/chef-stacktrace.out",
        },
      }

      def chef_apply
        PATH_MAPPING[:chef_apply][family]
      end

      def read_chef_stacktrace
        PATH_MAPPING[:read_chef_stacktrace][family]
      end

      def run
        Telemetry.timed_capture(:action, name: self.class.name.split("::").last) do
          perform_action
        end
      end

      def perform_action
        raise NotImplemented
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
