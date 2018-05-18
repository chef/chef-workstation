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

require "chef/handler"
require "chef/resource/directory"

module ChefRun
  class Reporter < ::Chef::Handler

    def report
      if exception
        Chef::Log.error("Creating exception report")
      else
        Chef::Log.info("Creating run report")
      end

      #ensure start time and end time are output in the json properly in the event activesupport happens to be on the system
      run_data = data
      run_data[:start_time] = run_data[:start_time].to_s
      run_data[:end_time] = run_data[:end_time].to_s

      Chef::FileCache.store("run-report.json", Chef::JSONCompat.to_json_pretty(run_data), 0640)
    end
  end
end
