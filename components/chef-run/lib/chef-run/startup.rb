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

require "chef-run/config"
require "chef-run/text"
require "chef-run/ui/terminal"
require "chef-run/telemeter/sender"
module ChefRun
  class Startup
    attr_reader :argv
    T = ChefRun::Text.cli

    def initialize(argv)
      @term_init = false
      @argv = argv.clone
      # Enable CLI output via Terminal. This comes first because other startup steps may
      # need to output to the terminal.
      init_terminal
    end

    def run
      # Some tasks we do only once in an installation:
      first_run_tasks

      # Call this every time, so that if we add or change ~/.chef-workstation
      # directory structure, we can be sure that it exists. Even with a
      # custom configuration, the .chef-workstation directory and subdirs
      # are required.
      setup_workstation_user_directories

      # Startup tasks that may change behavior based on configuration value
      # must be run after load_config
      load_config

      # Init logging using log level out of config
      setup_logging

      # Begin upload of previous session telemetry. (If telemetry is not enabled,
      # in config the uploader will clean up previous session(s) without sending)
      start_telemeter_upload

      # Launch the actual chef-run behavior
      start_chef_run

    # NOTE: Because these exceptions occur outside of the
    #       CLI handling, they won't be tracked in telemtry.
    #       We can revisit this once the pending error handling rework
    #       is underway.
    rescue ConfigPathInvalid => e
      UI::Terminal.output(T.error.bad_config_file(e.path))
    rescue ConfigPathNotProvided
      UI::Terminal.output(T.error.missing_config_path)
    rescue Mixlib::Config::UnknownConfigOptionError => e
      # Ideally we'd update the exception in mixlib to include
      # a field with the faulty value, line number, and nested context -
      # it's less fragile than depending on text parsing, which
      # is what we'll do for now.
      if e.message =~ /.*unsupported config value (.*)[.]+$/
        # TODO - levenshteinian distance to figure out
        # what they may have meant instead.
        UI::Terminal.output(T.error.invalid_config_key($1, Config.location))
      else
        # Safety net in case the error text changes from under us.
        UI::Terminal.output(T.error.unknown_config_error(e.message, Config.location))
      end
    rescue Tomlrb::ParseError => e
      UI::Terminal.output(T.error.unknown_config_error(e.message, Config.location))
    end

    def init_terminal
      UI::Terminal.init($stdout)
    end

    def first_run_tasks
      return if Dir.exist?(Config::WS_BASE_PATH)
      create_default_config
      setup_telemetry
    end

    def create_default_config
      UI::Terminal.output T.creating_config(Config.default_location)
      UI::Terminal.output ""
      FileUtils.mkdir_p(Config::WS_BASE_PATH)
      FileUtils.touch(Config.default_location)
    end

    def setup_telemetry
      require "securerandom"
      installation_id = SecureRandom.uuid
      File.write(Config.telemetry_installation_identifier_file, installation_id)

      # Tell the user we're anonymously tracking, give brief opt-out
      # and a link to detailed information.
      UI::Terminal.output T.telemetry_enabled(Config.location)
      UI::Terminal.output ""
    end

    def start_telemeter_upload
      ChefRun::Telemeter::Sender.start_upload_thread()
    end

    def setup_workstation_user_directories
      # Note that none of  these paths are customizable in config, so
      # it's safe to do before we load config.
      FileUtils.mkdir_p(Config::WS_BASE_PATH)
      FileUtils.mkdir_p(Config.base_log_directory)
      FileUtils.mkdir_p(Config.telemetry_path)
    end

    def load_config
      path = custom_config_path
      Config.custom_location(path) unless path.nil?
      Config.load
    end

    # Look for a user-supplied config path by  manually parsing the option.
    # Note that we can't use Mixlib::CLI for this.
    # To ensure that ChefRun::CLI initializes with correct
    # option defaults, we need to have configuraton loaded before initializing it.
    def custom_config_path
      argv.each_with_index do |arg, index|
        if arg == "--config-path" || arg == "-c"
          next_arg = argv[index + 1]
          raise ConfigPathNotProvided.new if next_arg.nil?
          raise ConfigPathInvalid.new(next_arg) unless File.file?(next_arg) && File.readable?(next_arg)
          return next_arg
        end
      end
      nil
    end

    def setup_logging
      ChefRun::Log.setup(Config.log.location, Config.log.level.to_sym)
      ChefRun::Log.info("Initialized logger")
    end

    def start_chef_run
      require "chef-run/cli"
      ChefRun::CLI.new(@argv).run
    end
    class ConfigPathNotProvided < StandardError; end
    class ConfigPathInvalid < StandardError
      attr_reader :path
      def initialize(path)
        @path = path
      end
    end
  end
end
