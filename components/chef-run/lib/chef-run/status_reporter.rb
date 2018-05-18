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

module ChefRun
  class StatusReporter

    def initialize(ui_element, prefix: nil, key: nil)
      @ui_element = ui_element
      @key = key
      @ui_element.update(prefix: prefix)
    end

    def update(msg)
      @ui_element.update({ @key => msg })
    end

    def success(msg)
      update(msg)
      @ui_element.success
    end

    def error(msg)
      update(msg)
      @ui_element.error
    end

  end
end
