module ChefWorkstation::Action::InstallChef
  class Windows < ChefWorkstation::Action::InstallChef::Base

    def perform_remote_install
      require "mixlib/install"
      installer = Mixlib::Install.new({
        platform: "windows",
        product_name: "chef",
        channel: :stable,
        shell_type: :ps1,
      })
      target_host.run_command! installer.install_command
    end

    # TODO: These methods are implemented, but are currently
    # not runnable - see explanation in InstallChef::Base
    def install_chef_to_target(remote_path)
      # While powershell does not mind the mixed path separators \ and /,
      # 'cmd.exe' definitely does - so we'll make the path cmd-friendly
      # before running the command
      cmd = "cmd /c msiexec /package #{remote_path.tr("/", "\\")} /quiet"
      target_host.run_command!(cmd)
    end

    def setup_remote_temp_path
      return @temppath if @temppath

      r = target_host.run_command!("Write-Host -NoNewline $env:TEMP")
      temppath = "#{r.stdout}\\chef-installer"

      # Failure here is acceptable - the dir could already exist
      target_host.run_command("New-Item -ItemType Directory -Force -Path #{temppath}")
      @temppath = temppath
    end
  end
end
