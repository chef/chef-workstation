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
      platform = train_to_mixlib(target_host.platform)
      c = {
        platform_version: platform[:version].to_s,
        platform: platform[:name],
        architecture: platform[:arch],
        product_name: "chef",
        version: :latest,
        # Need unstable until 14.1.1 is released
        channel: :unstable,
        platform_version_compatibility_mode: true
      }
      Mixlib::Install.new(c).artifact_info
    end

    # TODO: Omnitruck has the logic to deal with translaton but
    # mixlib-install is filtering out results incorrectly
    def train_to_mixlib(platform)
      case platform.name
       when /windows/
         { name: "windows", version: platform.release, arch: platform.arch }
       when "redhat", "centos"
         { name: "el", version: platform.release.to_i, arch: platform.arch }
       when "amazon"
         if platform.release.to_i > 2010 # legacy Amazon version 1
           { name: "el", version: "6", arch: platform.arch }
         else
           { name: "el", version: "7", arch: platform.arch }
         end
       else
         { name: platform.name, version: platform.release, arch: platform.arch }
      end
    end

    def download_to_workstation(url_path)
      require "chef-workstation/file_fetcher"
      ChefWorkstation::FileFetcher.fetch(url_path)
    end

    def upload_to_target(local_path)
      installer_dir = setup_remote_temp_path()
      remote_path = File.join(installer_dir, File.basename(local_path))
      target_host.upload_file(local_path, remote_path)
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
