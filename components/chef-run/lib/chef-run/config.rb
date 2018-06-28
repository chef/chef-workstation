#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
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
require "mixlib/config"
require "fileutils"
require "pathname"
require "chef-config/config"
require "chef-config/workstation_config_loader"

module ChefRun
  class Config
    WS_BASE_PATH = File.join(Dir.home, ".chef-workstation/")
    SUPPORTED_PROTOCOLS = %w{ssh winrm}

    class << self
      @custom_location = nil

      # Ensure when we extend Mixlib::Config that we load
      # up the workstation config since we will need that
      # to converge later
      def initialize_mixlib_config
        super
      end

      def custom_location(path)
        @custom_location = path
        raise "No config file located at #{path}" unless exist?
      end

      def default_location
        File.join(WS_BASE_PATH, "config.toml")
      end

      def telemetry_path
        File.join(WS_BASE_PATH, "telemetry")
      end

      def telemetry_session_file
        File.join(telemetry_path, "TELEMETRY_SESSION_ID")
      end

      def telemetry_installation_identifier_file
        File.join(WS_BASE_PATH, "installation_id")
      end

      def base_log_directory
        File.dirname(log.location)
      end

      # These paths are relative to the log output path, which is user-configurable.
      def error_output_path
        File.join(base_log_directory, "errors.txt")
      end

      def stack_trace_path
        File.join(base_log_directory, "stack-trace.log")
      end

      def using_default_location?
        @custom_location.nil?
      end

      def location
        using_default_location? ? default_location : @custom_location
      end

      def load
        if exist?
          from_file(location)
        end
      end

      def exist?
        File.exist? location
      end

      def reset
        @custom_location = nil
        super
      end
    end

    extend Mixlib::Config

    config_strict_mode true

    # When working on chef-run itself,
    # developers should set telemetry.dev to true
    # in their local configuration to ensure that dev usage
    # doesn't skew customer telemetry.
    config_context :telemetry do
      default(:dev, false)
      default(:enable, true)
    end

    config_context :log do
      default(:level, "warn")
      default(:location, File.join(WS_BASE_PATH, "logs/default.log"))
    end

    config_context :cache do
      default(:path, File.join(WS_BASE_PATH, "cache"))
    end

    config_context :connection do
      default(:default_protocol, "ssh")
      default(:default_user, nil)

      config_context :winrm do
        default(:ssl, false)
        default(:ssl_verify, true)
      end
    end

    config_context :dev do
      default(:spinner, "TTY::Spinner")
    end

    config_context :chef do
      # We want to use any configured chef repo paths or trusted certs in
      # ~/.chef/knife.rb on the user's workstation. But because they could have
      # config that could mess up our Policyfile creation later we reset the
      # ChefConfig back to default after loading that.
      ChefConfig::WorkstationConfigLoader.new(nil, ChefRun::Log).load
      default(:cookbook_repo_paths, [ChefConfig::Config[:cookbook_path]].flatten)
      default(:trusted_certs_dir, ChefConfig::Config[:trusted_certs_dir])
      ChefConfig::Config.reset
    end

    config_context :data_collector do
      default :url, nil
      default :token, nil
    end
  end
end
