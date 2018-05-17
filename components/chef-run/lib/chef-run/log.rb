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

require "mixlib/log"

module ChefRun
  class Log
    extend Mixlib::Log

    def self.setup(location, log_level)
      @location = location
      if location.is_a?(String)
        if location.casecmp("stdout") == 0
          location = $stdout
        else
          location = File.open(location, "w+")
        end
      end
      init(location)
      Log.level = log_level
    end

    def self.location
      @location
    end

  end
end
