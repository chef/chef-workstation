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

  before do
    mapping.top_level("example", :TestCommand, example_text, "unit/fixtures/command/cli_test_command")
    mapping.top_level("top-level", :TopLevel, example_text, "", subcommands: [
      mapping.create("subcommand", [:TopLevel, :Subcommand], example_text, ""),
    ])
  end

  it "defines the attributes correctly" do
    expect(mapping.have_command?("example")).to be true
    e = mapping.command_specs["example"]
    expect(e.require_path).to eq("unit/fixtures/command/cli_test_command")
    expect(e.make_banner).to eq("description\n\nUSAGE:\n")
  end

  it "lists the available commands" do
    expect(mapping.command_names).to match_array(%w{example top-level})
  end

  it "correctly stores a subcommand" do
    expect(mapping.command_specs["top-level"].subcommands.size).to eq(1)
    expect(mapping.command_specs["top-level"].subcommands.values[0].name).to eq("subcommand")
  end

  it "creates an instance of a command" do
    expect(mapping.instantiate("example")[0]).to be_an_instance_of(ChefWorkstation::Command::TestCommand)
  end
end
