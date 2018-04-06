require "chef-workstation/action/base"
require "fileutils"

module ChefWorkstation::Action::InstallChef
  class Base < ChefWorkstation::Action::Base
    def perform_action
      if already_installed_on_target?
        notify(:success, :already_installed)
        return
      end
      perform_local_install()
    end

    def perform_local_install
      package = lookup_artifact()
      notify(:downloading)
      local_path = download_to_workstation(package.url)
      notify(:uploading)
      remote_path = upload_to_target(local_path)
      notify(:installing)
      install_chef_to_target(remote_path)
      notify(:success, :install_complete)
    rescue => e
      msg = e.respond_to?(:message) ? e.message : nil
      notify(:error, msg)
      raise
    end

    def perform_remote_install
      raise NotImplementedError
    end

    def lookup_artifact
      require "mixlib/install"
      platform = connection.platform
      platform_name = platform.family == "windows" ? "windows" : platform.name
      c = {
        platform_version: platform.release,
        platform: platform_name,
        architecture: platform.arch,
        product_name: "chef",
        version: :latest,
        channel: :stable,
      }
      Mixlib::Install.new(c).artifact_info
    end

    def download_to_workstation(url_path)
      require "chef-workstation/file_fetcher"
      ChefWorkstation::FileFetcher.fetch(url_path)
    end

    def upload_to_target(local_path)
      installer_dir = setup_remote_temp_path()
      remote_path = File.join(installer_dir, File.basename(local_path))
      connection.upload_file(local_path, remote_path)
      remote_path
    end

    def setup_remote_temp_path
      # TODO - when we raise this, it's not caught
      # by top-level exception handling
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
