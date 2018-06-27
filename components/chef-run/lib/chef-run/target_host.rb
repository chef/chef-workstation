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

require "chef-run/log"
require "chef-run/error"
require "train"
module ChefRun
  class TargetHost
    attr_reader :config, :reporter, :backend, :transport_type
    # These values may exist in .ssh/config but will be ignored by train
    # in favor of its defaults unless we specify them explicitly.
    # See #apply_ssh_config
    SSH_CONFIG_OVERRIDE_KEYS = [:user, :port, :proxy]

    def self.instance_for_url(target, opts = {})
      opts = { target: @url }
      target_host = new(target, opts)
      target_host.connect!
      target_host
    end

    def initialize(host_url, opts = {}, logger = nil)
      @config = connection_config(host_url, opts, logger)
      @transport_type = Train.validate_backend(@config)
      apply_ssh_config(@config, opts) if @transport_type == "ssh"
      @train_connection = Train.create(@transport_type, config)
    end

    def connection_config(host_url, opts_in, logger)
      connection_opts = { target: host_url,
                          sudo: opts_in[:sudo] === false ? false : true,
                          www_form_encoded_password: true,
                          key_files: opts_in[:identity_file],
                          logger: ChefRun::Log }
      if opts_in.has_key? :ssl
        connection_opts[:ssl] = opts_in[:ssl]
        connection_opts[:self_signed] = (opts_in[:ssl_verify] === false ? true : false)
      end

      [:sudo_password, :sudo, :sudo_command, :password, :user].each do |key|
        connection_opts[key] = opts_in[key] if opts_in.has_key? key
      end
      Train.target_config(connection_opts)
    end

    def apply_ssh_config(config, opts_in)
      # If we don't provide certain options, they will be defaulted
      # within train - in the case of ssh, this will prevent the .ssh/config
      # values from being picked up.
      # Here we'll modify the returned @config to specify
      # values that we get out of .ssh/config, when they haven't
      # been explicitly given.
      host_cfg = ssh_config_for_host(config[:host])
      SSH_CONFIG_OVERRIDE_KEYS.each do |key|
        if host_cfg.has_key?(key) && opts_in[key].nil?
          config[key] = host_cfg[key]
        end
      end
    end

    def connect!
      return unless @backend.nil?
      @backend = train_connection.connection
      @backend.wait_until_ready
    rescue Train::UserError => e
      raise ConnectionFailure.new(e, config)
    rescue Train::Error => e
      # These are typically wrapper errors for other problems,
      # so we'll prefer to use e.cause over e if available.
      raise ConnectionFailure.new(e.cause || e, opts)
    end

    # Returns the user being used to connect
    def user
      config[:user]
    end

    def hostname
      config[:host]
    end

    def architecture
      platform.arch
    end

    def version
      platform.release
    end

    def base_os
      if platform.family == "windows"
        :windows
      elsif platform.linux?
        :linux
      else
        # TODO - this seems like it shouldn't happen here, when
        # all the caller is doing is asking about the OS
        raise ChefRun::TargetHost::UnsupportedTargetOS.new(platform.name)
      end
    end

    def platform
      backend.platform
    end

    def run_command!(command, sudo_as_user = false)
      result = run_command(command, sudo_as_user)
      if result.exit_status != 0
        raise RemoteExecutionFailed.new(@config[:host], command, result)
      end
      result
    end

    def run_command(command, sudo_as_user = false)
      if config[:sudo] && sudo_as_user && base_os == :linux
        command = "-u #{config[:user]} #{command}"
      end
      backend.run_command command
    end

    def upload_file(local_path, remote_path)
      backend.upload(local_path, remote_path)
    end

    # Returns the installed chef version as a Gem::Version,
    # or raised ChefNotInstalled if chef client version manifest can't
    # be found.
    def installed_chef_version
      return @installed_chef_version if @installed_chef_version
      # Note: In the case of a very old version of chef (that has no manifest - pre 12.0?)
      #       this will report as not installed.
      manifest = get_chef_version_manifest()
      raise ChefNotInstalled.new if manifest == :not_found
      # We'll split the version here because  unstable builds (where we currently
      # install from) are in the form "Major.Minor.Build+HASH" which is not a valid
      # version string.
      @installed_chef_version = Gem::Version.new(manifest["build_version"].split("+")[0])
    end

    MANIFEST_PATHS = {
      # TODO - use a proper method to query the win installation path -
      #        currently we're assuming the default, but this can be customized
      #        at install time.
      #        A working approach is below - but it runs very slowly in testing
      #        on a virtualbox windows vm:
      #        (over winrm) Get-WmiObject Win32_Product | Where {$_.Name -match 'Chef Client'}
      windows: "c:\\opscode\\chef\\version-manifest.json",
      linux: "/opt/chef/version-manifest.json"
    }

    def get_chef_version_manifest
      path = MANIFEST_PATHS[base_os()]
      manifest = backend.file(path)
      return :not_found unless manifest.file?
      JSON.parse(manifest.content)
    end

    private

    def train_connection
      @train_connection
    end

    def ssh_config_for_host(host)
      require "net/ssh"
      Net::SSH::Config.for(host)
    end

    class RemoteExecutionFailed < ChefRun::ErrorNoLogs
      attr_reader :stdout, :stderr
      def initialize(host, command, result)
        super("CHEFRMT001",
              command,
              result.exit_status,
              host,
              result.stderr.empty? ? result.stdout : result.stderr)
      end
    end

    class ConnectionFailure < ChefRun::ErrorNoLogs
      # TODO: Currently this only handles sudo-related errors;
      # we should also look at e.cause for underlying connection errors
      # which are presently only visible in log files.
      def initialize(original_exception, connection_opts)
        sudo_command = connection_opts[:sudo_command]
        init_params =
          #  Comments below show the original_exception.reason values to check for instead of strings,
          #  after train 1.4.12 is consumable.
          case original_exception.message # original_exception.reason
          when /Sudo requires a password/ # :sudo_password_required
            "CHEFTRN003"
          when /Wrong sudo password/ #:bad_sudo_password
            "CHEFTRN004"
          when /Can't find sudo command/, /No such file/, /command not found/ # :sudo_command_not_found
            # NOTE: In the /No such file/ case, reason will be nil - we still have
            # to check message text. (Or PR to train to handle this case)
            ["CHEFTRN005", sudo_command] # :sudo_command_not_found
          when /Sudo requires a TTY.*/   # :sudo_no_tty
            "CHEFTRN006"
          else
            ["CHEFTRN999", original_exception.message]
          end
        super(*(Array(init_params).flatten))
      end
    end

    class ChefNotInstalled < StandardError; end

    class UnsupportedTargetOS < ChefRun::ErrorNoLogs
      def initialize(os_name); super("CHEFTARG001", os_name); end
    end
  end
end
