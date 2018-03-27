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
    attr_reader :config, :reporter, :backend

    def initialize(host_url, opts = {}, logger = nil)
      target_url = maybe_add_default_scheme(host_url)
      conn_opts = { sudo: opts.has_key?(:sudo) ? opts[:sudo] : false,
                    target: target_url,
                    key_files: opts[:key_file],
                    logger: ChefWorkstation::Log }
      @config = Train.target_config(conn_opts)
      @type = Train.validate_backend(@config)
      @train_connection = Train.create(@type, config)
    end

    def connect!
      @backend ||= @train_connection.connection
    end

    def platform
      backend.platform
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
  end
end
