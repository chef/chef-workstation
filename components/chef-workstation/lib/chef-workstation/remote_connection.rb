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
    attr_reader :config, :reporter, :connection, :sudo_ok
    # TODO let's figure out the logging and UI-upating paths - do we want separate interfaces?
    #
    # Open connection to target.
    def self.make_connection(target, opts = {})
      conn = RemoteConnection.new(target, opts)
      conn.connect!
      conn
    end

    def initialize(host_url, opts = {}, logger = nil)
      target_url = clean_host_url(host_url)
      conn_opts = { sudo: opts.has_key?(:sudo) ? opts[:sudo] : false,
                    target: target_url,
                    key_files: opts[:key_file],
                    logger: ChefWorkstation::Log }
      @config = Train.target_config(conn_opts)
      @type = Train.validate_backend(@config)
      @train_connection = Train.create(@type, config)
    end

    def connect!
      if @connection.nil?
        @connection = @train_connection.connection
        @sudo_ok = connection.run_command("sudo ls").exit_status == 0
      end
    end

    def os
      # TODO raise notconnected if !connection
      connection.os
    end

    def run_command(command)
      # TODO raise notconnected if !connection
      c = connection.run_command(command)
      # require 'pry'; binding.pry
      # ChefWorkstation::Log.debug(c.stdout)
      # ChefWorkstation::Log.error(c.stderr)
      c
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
