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

require "net/http"
require "uri"
require "chef-run/config"
require "chef-run/log"

module ChefRun
  class FileFetcher
    class << self
      # Simple fetcher of an http(s) url. Returns the local path
      # of the downloaded file.
      def fetch(path)
        cache_path = ChefRun::Config.cache.path
        FileUtils.mkdir_p(cache_path)
        url = URI.parse(path)
        name = File.basename(url.path)
        local_path = File.join(cache_path, name)

        # TODO header check for size or checksum?
        return local_path if File.exist?(local_path)

        download_file(url, local_path)
        local_path
      end

      def download_file(url, local_path)
        temp_path = "#{local_path}.downloading"
        file = open(temp_path, "wb")
        ChefRun::Log.debug "Downloading: #{temp_path}"
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
      end
    end
  end
end
