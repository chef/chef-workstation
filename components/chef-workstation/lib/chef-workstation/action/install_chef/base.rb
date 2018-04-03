require "chef-workstation/action/base"
require "chef-workstation/config"
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
      # TODO: Support an option to specify perform_local/remote_install.
      perform_local_install
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
    rescue => e
      msg = e.respond_to?(:message) ? e.message : T.aborted
      reporter.error(T.error(msg))
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
      require "uri"
      require "net/http"

      FileUtils.mkdir_p(ChefWorkstation::Config.cache.path)
      url = URI.parse(url_path)
      name = File.basename(url.path)
      local_path = File.join(ChefWorkstation::Config.cache.path,
                             name)

      return local_path if File.exist?(local_path)

      temp_path = "#{local_path}.downloading"
      file = open(temp_path, "wb")
      ChefWorkstation::Log.debug "Downloading: #{temp_path}"
      Net::HTTP.start(url.host) do |http|
        begin
          http.request_get(url.path) do |resp|
            resp.read_body do |segment|
              file.write(segment)
            end
          end
        rescue e
          @error = true
          raise
        ensure
          file.close()
          # If any failures occurred, don't risk keeping
          # an incomplete download that we'll see as 'cached'
          if @error
            FileUtils.rm_f(temp_path)
          else
            FileUtils.mv(temp_path, local_path)
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
