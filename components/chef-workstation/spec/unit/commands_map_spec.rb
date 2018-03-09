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

require "spec_helper"
require "chef-workstation/commands_map"

RSpec.describe ChefWorkstation::CommandsMap do
  subject(:mapping) { ChefWorkstation::CommandsMap.new }

  before do
    mapping.top_level("example", :Example)
    mapping.top_level("hypenated-example", :HyphenatedExample)
    mapping.top_level("explicit-path-example", :TestCommand, require_path: "unit/fixtures/command/cli_test_command")
    mapping.top_level("top-level", :TopLevel, subcommands: [mapping.create("subcommand", :Subcommand)])
  end

  it "defines a subcommand mapping" do
    expect(mapping.have_command?("example")).to be true
  end

  it "infers a non-hypenated command's require path" do
    expect(mapping.command_specs["example"].require_path).to eq("chef-workstation/command/example")
  end

  it "infers a hyphenated command's require path" do
    expect(mapping.command_specs["hypenated-example"].require_path).to eq("chef-workstation/command/hypenated_example")
  end

  it "lists the available commands" do
    expect(mapping.command_names).to match_array(%w{example hypenated-example explicit-path-example top-level})
  end

  it "correctly stores a subcommand" do
    expect(mapping.command_specs["top-level"].subcommands.size).to eq(1)
    expect(mapping.command_specs["top-level"].subcommands.values[0].name).to eq("subcommand")
  end

  it "creates an instance of a command" do
    expect(mapping.instantiate("explicit-path-example")[0]).to be_an_instance_of(ChefWorkstation::Command::TestCommand)
  end
end
