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
require "chef-workstation/commands_map"
require "chef-workstation/command/target/converge"

RSpec.describe ChefWorkstation::Command::Target::Converge do
  let(:cmd_spec) { instance_double(ChefWorkstation::CommandsMap::CommandSpec) }
  subject(:cmd) do
    ChefWorkstation::Command::Target::Converge.new(cmd_spec)
  end

  describe "#validate_params" do
    it "raises an error if not enough params are specified" do
      expect { cmd.validate_params([]) }.to raise_error(/must supply/)
      expect { cmd.validate_params(%w{one two}) }.to raise_error(/must supply/)
    end

    it "raises an error if attributes are not specified as key value pairs" do
      expect { cmd.validate_params(%w{one two three four}) }.to raise_error(/four.+key=value/)
      expect { cmd.validate_params(%w{one two three four=value five six=value}) }.to raise_error(/five.+key=value/)
      expect { cmd.validate_params(%w{one two three non.word=value}) }.to raise_error(/non\.word.+key=value/)
    end
  end

  describe "#format_attributes" do
    it "parses attributes into a hash" do
      provided = %w{key1=value key2=1 key3=true key4=FaLsE key5=0777}
      expected = {
        "key1" => "value",
        "key2" => 1,
        "key3" => true,
        "key4" => false,
        "key5" => "0777"
      }
      expect(cmd.format_attributes(provided)).to eq(expected)
    end

  end
end
