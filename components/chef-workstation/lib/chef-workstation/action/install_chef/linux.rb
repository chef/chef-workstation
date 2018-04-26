module ChefWorkstation::Action::InstallChef
  class Linux < ChefWorkstation::Action::InstallChef::Base
    def already_installed_on_target?
      r = target_host.run_command("test -f /opt/chef/bin/chef-client")
      r.exit_status == 0
    end

    def install_chef_to_target(remote_path)
      install_cmd = case File.extname(remote_path)
                    when ".rpm"
                      "rpm -Uvh #{remote_path}"
                    when ".deb"
                      "dpkg -i #{remote_path}"
                    end
      target_host.run_command!(install_cmd)
      nil
    end

    def setup_remote_temp_path
      installer_dir = "/tmp/chef-installer"
      target_host.run_command!("mkdir -p #{installer_dir}")
      target_host.run_command!("chmod 777 #{installer_dir}")
      installer_dir
    end
  end
end
