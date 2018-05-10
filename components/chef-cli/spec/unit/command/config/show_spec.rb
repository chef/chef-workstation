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

require "spec_helper"
require "chef-cli/command/config/show"

RSpec.describe ChefCLI::Command::Config::Show do
  let(:cmd_spec) { instance_double(ChefCLI::CommandsMap::CommandSpec, qualified_name: "blah") }
  subject(:cmd) do
    ChefCLI::Command::Config::Show.new(cmd_spec)
  end

  describe "run" do
    before do
      ChefCLI::Config.telemetry.dev = true
    end

    it "prints config to screen" do
      expect { cmd.run([]) }.to output(/dev = true/).to_terminal
    end
  end
end
