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
  let(:example_text) { double("text", description: "description", usage: "USAGE:\n") }
  let(:example_cmd) { mapping.top_level("example", :TestCommand, example_text, "unit/fixtures/command/cli_test_command") }
  let(:subcmd1) { mapping.create("subcommand1", [:TopLevel, :Subcommand], example_text, "unit/fixtures/command/cli_test_command") }
  let(:subcmd2) { mapping.create("subcommand2", :AliasedCommand, example_text, "unit/fixtures/command/cli_test_command", cmd_alias: "subby") }
  let(:subcommands) { [subcmd1, subcmd2] }
  let(:parent_cmd) { mapping.top_level("top-level", :TopLevel, example_text, "", subcommands: subcommands) }

  before do
    # Referencing these will cause themt o be instantiated and added to the map:
    example_cmd
    parent_cmd
  end

  it "defines the attributes correctly" do
    expect(mapping.have_command_or_alias?("example")).to be true
    e = mapping.command_specs["example"]
    expect(e.require_path).to eq("unit/fixtures/command/cli_test_command")
    expect(e.make_banner).to eq("description\n\nUSAGE:\n")
  end

  it "lists the available commands" do
    expect(mapping.command_names).to match_array(%w{example top-level})
  end

  it "correctly stores a subcommand" do
    expect(mapping.command_specs["top-level"].subcommands.size).to eq(2)
    expect(mapping.command_specs["top-level"].subcommands.values[0]).to eq subcmd1
  end

  it "creates an instance of a command" do
    expect(mapping.instantiate("example")[0]).to be_an_instance_of(ChefWorkstation::Command::TestCommand)
  end

  it "creates an instance of the correct command when an alias is used" do
    expect(mapping.instantiate("subby")[0]).to be_an_instance_of(ChefWorkstation::Command::AliasedCommand)
  end

  it "assigns qualified names to commands correctly" do
    ChefWorkstation.assign_parentage!(mapping.command_specs)
    expect(subcmd1.qualified_name).to eq "top-level subcommand1"
    expect(subcmd2.qualified_name).to eq "top-level subcommand2"
    expect(example_cmd.qualified_name).to eq "example"
    expect(parent_cmd.qualified_name).to eq "top-level"
  end

end
