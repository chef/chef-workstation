require "chef-workstation/action/base"
require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/action/errors"
require "fileutils"
module ChefWorkstation::Action::InstallChef
  class Base < ChefWorkstation::Action::Base
    T = ChefWorkstation::Text.actions.install_chef
    # Create connection action instance based on targt OS.
    def perform_action
      if already_installed_on_target?
        reporter.success(T.client_already_installed)
        return
      end
      # TODO 2018-03-21  WinRMFS/WinRM interface mismatch bug
      # Currently, upload_to_target fails over WinRM due to:
      # NoMethodError: undefined method `shell' for #<WinRM::Shells::Powershell:0x00563332151498>
      #  winrm-fs/lib/winrm-fs/file_manager.rb:110:in `upload'
      #  train/lib/train/transports/winrm_connection.rb:67:in `upload'
      # This means that until we can look closer at that,
      # windows installations are required to be remote.
      if connection.platform.family == "windows"
        reporter.update(T.installing)
        perform_remote_install
      else
        perform_local_install
      end
    end

    def perform_local_install
      package = lookup_artifact()
      reporter.update(T.downloading)
      local_path = download_to_workstation(package.url)
      reporter.update(T.uploading)
      remote_path = upload_to_target(local_path)
      reporter.update(T.installing)
      install_chef_to_target(remote_path)
      reporter.success(T.success)
    rescue RuntimeError => e
      reporter.error(T.error(e.message))
      raise
    end

    def perform_remote_install
      raise NotImplementedError
    end

    def lookup_artifact
      require "mixlib/install"
      platform = connection.platform
      c = {
        platform_version: platform.release,
        platform: platform.name,
        architecture: platform.arch,
        product_name: "chef",
        version: :latest,
        channel: :stable,
      }
      Mixlib::Install.new(c).artifact_info
    end

    def download_to_workstation(url_path)
      require "uri"
      require "net/http"

      FileUtils.mkdir_p(ChefWorkstation::Config.cache.path)
      url = URI.parse(url_path)
      name = File.basename(url.path)
      local_path = File.join(ChefWorkstation::Config.cache.path,
                             name)

      return local_path if File.exist?(local_path)

      file = open(local_path, "wb")
      ChefWorkstation::Log.debug "Downloading: #{local_path}"
      Net::HTTP.start(url.host) do |http|
        begin
          http.request_get(url.path) do |resp|
            resp.read_body do |segment|
              file.write(segment)
            end
          end
        rescue => e
          log.error e.message
          error = true
        ensure
          file.close()
          if error
            File.delete(local_path)
          end
        end
      end
      local_path
    end

    def upload_to_target(local_path)
      installer_dir = setup_remote_temp_path()
      remote_path = File.join(installer_dir, File.basename(local_path))
      connection.upload_file(local_path, remote_path)
      remote_path
    end

    def setup_remote_temp_path
      raise NotImplementedError
    end

    def already_installed_on_target?
      raise NotImplementedError
    end

    def install_chef_to_target(remote_path)
      raise NotImplementedError
    end
  end
end
