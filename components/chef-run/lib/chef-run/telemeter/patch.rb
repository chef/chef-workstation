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

class Telemetry
  class Session
    # The telemetry session data is normally kept in .chef, which we don't have.
    def session_file
      ChefRun::Config.telemetry_session_file.freeze
    end
  end

  def deliver(data = {})
    if ChefRun::Telemeter.instance.enabled?
      payload = event.prepare(data)
      client.await.fire(payload)
    end
  end
end
