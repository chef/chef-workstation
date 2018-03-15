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
require "chef-workstation/command/base"
require "chef-workstation/commands_map"

RSpec.describe ChefWorkstation::Command::Base do
  let(:cmd_spec) { instance_double(ChefWorkstation::CommandsMap::CommandSpec, name: "cmd", subcommands: []) }
  subject(:cmd) do
    ChefWorkstation::Command::Base.new(cmd_spec)
  end

  describe "run" do
    it "raises an NotImplementedError" do
      expect { cmd.run([]) }.to raise_error(NotImplementedError)
    end
  end

  describe "run_with_default_options" do
    it "prints the help text" do
      expect { cmd.run_with_default_options(["help"]) }.to output(/Command banner not set.+-c, --config PATH/m).to_stdout
    end
  end
end
