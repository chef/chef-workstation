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

require "chef-workstation/command/base"

module ChefWorkstation
  module Command
    class TestCommand < ChefWorkstation::Command::Base

      def self.reset!
        @test_result = nil
      end

      def self.test_result
        @test_result
      end

      def self.test_result=(result)
        @test_result = result
      end

      def run(params)
        self.class.test_result = { :status => :success, :params => params }
        23
      end
    end
  end
end
