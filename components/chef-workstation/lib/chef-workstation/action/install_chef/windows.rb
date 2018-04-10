module ChefWorkstation::Action::InstallChef
  class Windows < ChefWorkstation::Action::InstallChef::Base
    def already_installed_on_target?
      # TODO: 2018-03-20 Let's take a look at ways to query installed packages.
      #       This method (checking if file exists) works for now, but
      #       the customer could have installed chef client anywhere.
      # Another option is below - but it runs very slowly in testing:
      # Get-WmiObject Win32_Product | Where {$_.Name -match 'Chef Client'}
      cmd = <<-EOM.delete("\n")
      if (Test-Path 'c:\\opscode\\chef\\bin\\chef-client' -PathType Leaf) {
        Write-Host -NoNewline 'true'
      }
      EOM
      r = connection.run_command!(cmd)
      r.stdout == "true"
    end

    def perform_remote_install
      require "mixlib/install"
      installer = Mixlib::Install.new({
        platform: "windows",
        product_name: "chef",
        channel: :stable,
        shell_type: :ps1,
      })
      connection.run_command! installer.install_command
    end

    # TODO: These methods are implemented, but are currently
    # not runnable - see explanation in InstallChef::Base
    def install_chef_to_target(remote_path)
      # While powershell does not mind the mixed path separators \ and /,
      # 'cmd.exe' definitely does - so we'll make the path cmd-friendly
      # before running the command
      cmd = "cmd /c msiexec /package #{remote_path.tr("/", "\\")} /quiet"
      connection.run_command!(cmd)
    end

    def setup_remote_temp_path
      return @temppath if @temppath

      r = connection.run_command!("Write-Host -NoNewline $env:TEMP")
      temppath = "#{r.stdout}\\chef-installer"

      # Failure here is acceptable - the dir could already exist
      connection.run_command("New-Item -ItemType Directory -Force -Path #{temppath}")
      @temppath = temppath
    end
  end
end
