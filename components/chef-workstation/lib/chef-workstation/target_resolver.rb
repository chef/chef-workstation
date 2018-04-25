require "chef-workstation/remote_connection"

module ChefWorkstation
  class TargetResolver
    def initialize(unparsed_target, conn_options)
      @unparsed_target = unparsed_target
      @conn_options = conn_options
    end

    def targets
      @targets ||= @unparsed_target.split(",").map do |target|
        RemoteConnection.new(target, @conn_options)
      end
    end
  end
end
