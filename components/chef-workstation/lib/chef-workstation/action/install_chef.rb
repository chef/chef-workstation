require "chef-workstation/action/install_chef/base"
require "chef-workstation/action/install_chef/windows"
require "chef-workstation/action/install_chef/linux"

module ChefWorkstation::Action::InstallChef
  def self.instance_for_target(target_host, opts = { check_only: false })
    opts[:target_host] = target_host
    case target_host.base_os
    when :windows then Windows.new(opts)
    when :linux then Linux.new(opts)
    end
  end
end
