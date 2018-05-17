#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "chef-run/action/base"
require "fileutils"

module ChefRun::Action::InstallChef
  class Base < ChefRun::Action::Base
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
    rescue ChefRun::TargetHost::ChefNotInstalled
      if config[:check_only]
        raise ClientNotInstalled.new()
      end
      perform_local_install
    end

    def name
      # We have subclasses - so this'll take the qualified name
      # eg InstallChef::Windows, etc
      self.class.name.split("::")[-2..-1].join("::")
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
      require "chef-run/file_fetcher"
      ChefRun::FileFetcher.fetch(url_path)
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

  class ClientNotInstalled < ChefRun::ErrorNoLogs
    def initialize(); super("CHEFINS002"); end
  end

  class ClientOutdated < ChefRun::ErrorNoLogs
    def initialize(current_version, target_version)
      super("CHEFINS003", current_version, target_version)
    end
  end
end
