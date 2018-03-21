require "chef-workstation/action/install_chef/base"
require "chef-workstation/action/install_chef/windows"
require "chef-workstation/action/install_chef/linux"
require "chef-workstation/action/errors"

module ChefWorkstation::Action::InstallChef
  def self.instance_for_target(conn, opts = {})
    opts[:connection] = conn
    p = conn.platform
    if p.family == "windows" # Family is reliable even when mocking; `windows?` is not.
      Windows.new(opts)
    elsif p.linux?
      Linux.new(opts)
    else
      raise ChefWorkstation::Action::Errors::UnsupportedTargetOS.new(p.name)
    end
  end
end
