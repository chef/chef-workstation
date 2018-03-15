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

require "chef-workstation/log"
require "train"

module ChefWorkstation
  class RemoteConnection
    attr_reader :config, :reporter, :connection
    # TODO let's figure out the logging and UI-upating paths - do we want separate interfaces?
    #
    # Open connection to target.
    def self.make_connection(target, opts = {})
      conn = RemoteConnection.new(target, opts)
      conn.connect!
    rescue e

      puts "Error: #{e.message}"

      # There are a large number of errors out of train that we could handle explicitly
      # and provide better responses for.
    end

    def initialize(host_url, opts = {}, logger = nil)
      target_url = clean_host_url(host_url)
      # TODO Temp so I can stop getting spammed withoutput
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      conn_opts = { sudo: opts.has_key?(:sudo) ? opts[:sudo] : false,
                    logger: logger,
                    # TODO  shoudl default to shell user, but this shouldn't override user@ form.
                    user: ENV['USER'],
                    target: target_url,
                    key_files: opts[:key_file],
                    logger: ChefWorkstation::Log }
      @config = Train.target_config(conn_opts)
      # TODO - handling user in url vs user in
      @type = Train.validate_backend(@config)
      @train_connection = Train.create(@type, config)
    end

    def connect!
      @connection ||= @train_connection.connection
    end

    def os
      # TODO raise notconnected if !connection
      connection.os
    end

    def run_command(command)
      # TODO raise notconnected if !connection
      connection.run_command command
    end

    def upload_file(local_path, remote_path)
      # TODO raise notconnected if !connection
      connection.upload(local_path, remote_path)
    end

    def clean_host_url(url)
      if url =~ /^ssh|winrm:\/\//
        url
      else
        "ssh://#{url}"
      end
    end
  end
end
