require "chef-workstation/action/install_chef/base"
require "chef-workstation/action/install_chef/windows"
require "chef-workstation/action/install_chef/linux"

module ChefWorkstation::Action::InstallChef
  def self.instance_for_target(conn, opts = {})
    opts[:connection] = conn
    p = conn.platform
    if p.family == "windows" # Family is reliable even when mocking; `windows?` is not.
      Windows.new(opts)
    elsif p.linux?
      Linux.new(opts)
    else
      raise UnsupportedTargetOS.new(p.name)
    end
  end

  class UnsupportedTargetOS < ChefWorkstation::Error
    def initialize(os_name); super("CHEFINS001", os_name); end
  end

end
