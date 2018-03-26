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
class ChefWorkstation::RemoteConnection
  attr_reader :config, :reporter, :backend

  def self.make_connection(target, opts = {})
    conn = self.new(target, opts)
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
    # NOTE: when sudo is enabled at the connection level,
    # it seems that retrieving the connection is enough to
    # cause it to connect; but it seems that when is not enabled,
    # the connection is not yet made until we trye to actually invoke it.
    if @backend.nil?
      @backend = @train_connection.connection
      # Run an invalid command to establish the connection
      @backend.run_command("invalid")
    end
    @backend
  end

  def platform
    backend.platform
  end

  def run_command!(command)
    result = backend.run_command command
    if result.exit_status != 0
      raise RemoteExecutionFailed.new(@config[:host], command, result)
    end
    result
  end

  def run_command(command)
    backend.run_command command
  end

  def upload_file(local_path, remote_path)
    backend.upload(local_path, remote_path)
  end

  def maybe_add_default_scheme(url)
    if url =~ /^ssh|winrm|mock:\/\//
      url
    else
      "ssh://#{url}"
    end
  end
  class RemoteExecutionFailed < ChefWorkstation::ErrorNoLogs
    attr_reader :stdout, :stderr
    def initialize(host, command, result)
      super("RMT001",  host, command,
            result.stderr.empty? ? result.stdout : result.stderr,
            result.exit_status)
    end
  end
end
