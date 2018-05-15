require "chef-cli/action/base"
require "fileutils"

module ChefCLI::Action::InstallChef
  class Base < ChefCLI::Action::Base
    MIN_CHEF_VERSION = Gem::Version.new("14.1.1")

    def perform_action
      if target_host.installed_chef_version >= MIN_CHEF_VERSION
        notify(:already_installed)
        return
      end
      raise ClientOutdated.new(target_host.installed_chef_version, MIN_CHEF_VERSION)
      # NOTE: 2018-05-10 below is an intentionally dead code path that
      #       will get re-visited once we determine how we want automatic
      #       upgrades to behave.
      # @upgrading = true
      # perform_local_install
    rescue ChefCLI::TargetHost::ChefNotInstalled
      if config[:check_only]
        raise ClientNotInstalled.new()
      end
      perform_local_install
    end

    def upgrading?
      @upgrading
    end

    def perform_local_install
      package = lookup_artifact()
      notify(:downloading)
      local_path = download_to_workstation(package.url)
      notify(:uploading)
      remote_path = upload_to_target(local_path)
      notify(:installing)
      install_chef_to_target(remote_path)
      notify(:install_complete)
    end

    def perform_remote_install
      raise NotImplementedError
    end

    def lookup_artifact
      return @artifact_info if @artifact_info
      require "mixlib/install"
      c = train_to_mixlib(target_host.platform)
      Mixlib::Install.new(c).artifact_info
    end

    def version_to_install
      lookup_artifact.version
    end

    def train_to_mixlib(platform)
      opts = {
        platform_version: platform.release,
        platform: platform.name,
        architecture: platform.arch,
        product_name: "chef",
        version: :latest,
        channel: :stable,
        platform_version_compatibility_mode: true
      }
      case platform.name
      when /windows/
        opts[:platform] = "windows"
      when "redhat", "centos"
        opts[:platform] = "el"
      when "suse"
        opts[:platform] = "sles"
      when "amazon"
        opts[:platform] = "el"
        if platform.release.to_i > 2010 # legacy Amazon version 1
          opts[:platform_version] = "6"
        else
          opts[:platform_version] = "7"
        end
      end
      opts
    end

    def download_to_workstation(url_path)
      require "chef-cli/file_fetcher"
      ChefCLI::FileFetcher.fetch(url_path)
    end

    def upload_to_target(local_path)
      installer_dir = setup_remote_temp_path()
      remote_path = File.join(installer_dir, File.basename(local_path))
      target_host.upload_file(local_path, remote_path)
      remote_path
    end

    def setup_remote_temp_path
      raise NotImplementedError
    end

    def install_chef_to_target(remote_path)
      raise NotImplementedError
    end
  end

  class ClientNotInstalled < ChefCLI::ErrorNoLogs
    def initialize(); super("CHEFINS002"); end
  end

  class ClientOutdated < ChefCLI::ErrorNoLogs
    def initialize(current_version, target_version)
      super("CHEFINS003", current_version, target_version)
    end
  end
end
