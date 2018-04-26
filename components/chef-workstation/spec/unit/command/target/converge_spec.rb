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
  let(:cmd_spec) { instance_double(ChefWorkstation::CommandsMap::CommandSpec, qualified_name: "blah") }
  subject(:cmd) do
    ChefWorkstation::Command::Target::Converge.new(cmd_spec)
  end
  OptionValidationError = ChefWorkstation::Command::Target::Converge::OptionValidationError

  describe "#validate_params" do
    it "raises an error if not enough params are specified" do
      params = [
        [],
        %w{one}
      ]
      params.each do |p|
        expect { cmd.validate_params(p) }.to raise_error(OptionValidationError) do |e|
          e.id == "CHEFVAL002"
        end
      end
    end

    it "succeeds if the second command is a valid file path" do
      params = %w{target /some/path}
      expect(File).to receive(:exist?).with("/some/path").and_return true
      expect { cmd.validate_params(params) }.to_not raise_error
    end

    it "succeeds if the second argument looks like a cookbook name" do
      params = [
        %w{target cb},
        %w{target cb::recipe}
      ]
      params.each do |p|
        expect { cmd.validate_params(p) }.to_not raise_error
      end
    end

    it "raises an error if the second argument is neither a valid path or a valid cookbook name" do
      params = %w{target weird%name}
      expect { cmd.validate_params(params) }.to raise_error(OptionValidationError) do |e|
        e.id == "CHEFVAL004"
      end
    end

    it "raises an error if properties are not specified as key value pairs" do
      params = [
        %w{one two three four},
        %w{one two three four=value five six=value},
        %w{one two three non.word=value},
      ]
      params.each do |p|
        expect { cmd.validate_params(p) }.to raise_error(OptionValidationError) do |e|
          e.id == "CHEFVAL003"
        end
      end
    end
  end

  describe "#format_properties" do
    it "parses properties into a hash" do
      provided = %w{key1=value key2=1 key3=true key4=FaLsE key5=0777 key6=https://some.website key7=num1and2digit}
      expected = {
        "key1" => "value",
        "key2" => 1,
        "key3" => true,
        "key4" => false,
        "key5" => "0777",
        "key6" => "https://some.website",
        "key7" => "num1and2digit",
      }
      expect(cmd.format_properties(provided)).to eq(expected)
    end
  end

  describe "#parse_converge_args" do
    let(:converge_args) { Hash.new }

    context "when trying to converge a recipe" do
      let(:cli_arguments) { [p] }
      let(:recipe_lookup) { instance_double(ChefWorkstation::RecipeLookup) }
      let(:status_msg) { ChefWorkstation::Text.status.converge.converging_recipe(p) }
      let(:cookbook) { double("cookbook") }
      let(:recipe_path) { "/recipe/path" }

      context "as a path" do
        let(:p) { recipe_path }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return true
          actual1, actual2 = cmd.parse_converge_args(converge_args, cli_arguments)
          expect(actual1).to eq({ recipe_path: p })
          expect(actual2).to eq(status_msg)
        end
      end

      context "as a cookbook name" do
        let(:p) { "cb_name" }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return false
          expect(ChefWorkstation::RecipeLookup).to receive(:new).and_return(recipe_lookup)
          expect(recipe_lookup).to receive(:split).with(p).and_return([p])
          expect(recipe_lookup).to receive(:load_cookbook).with(p).and_return(cookbook)
          expect(recipe_lookup).to receive(:find_recipe).with(cookbook, nil).and_return(recipe_path)
          actual1, actual2 = cmd.parse_converge_args(converge_args, cli_arguments)
          expect(actual1).to eq({ recipe_path: recipe_path })
          expect(actual2).to eq(status_msg)
        end
      end

      context "as a cookbook and recipe name" do
        let(:cookbook_name) { "cb_name" }
        let(:recipe_name) { "recipe_name" }
        let(:p) { cookbook_name + "::" + recipe_name }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return false
          expect(ChefWorkstation::RecipeLookup).to receive(:new).and_return(recipe_lookup)
          expect(recipe_lookup).to receive(:split).with(p).and_return([cookbook_name, recipe_name])
          expect(recipe_lookup).to receive(:load_cookbook).with(cookbook_name).and_return(cookbook)
          expect(recipe_lookup).to receive(:find_recipe).with(cookbook, recipe_name).and_return(recipe_path)
          actual1, actual2 = cmd.parse_converge_args(converge_args, cli_arguments)
          expect(actual1).to eq({ recipe_path: recipe_path })
          expect(actual2).to eq(status_msg)
        end
      end

    end

    context "when trying to converge a resource" do
      let(:cli_arguments) { %w{directory foo prop1=val1 prop2=val2} }
      it "returns the resource information" do
        actual1, actual2 = cmd.parse_converge_args(converge_args, cli_arguments)
        expect(actual1).to eq({
          properties: { "prop1" => "val1", "prop2" => "val2" },
          resource_type: "directory",
          resource_name: "foo"
        })
        msg = ChefWorkstation::Text.status.converge.converging_resource("directory[foo]")
        expect(actual2).to eq(msg)
      end
    end
  end

  describe "#run" do
    let(:params) { %w{target /some/path} }
    let(:target_host) { instance_double(ChefWorkstation::TargetHost, hostname: "target") }
    let(:reporter) { instance_double(ChefWorkstation::StatusReporter) }
    let(:installer) { instance_double(ChefWorkstation::Action::InstallChef::Linux) }
    let(:converger) { instance_double(ChefWorkstation::Action::ConvergeTarget) }
    it "installs chef and runs the resource" do
      expect(cmd).to receive(:cli_arguments).and_return(params).exactly(3).times
      expect(cmd).to receive(:validate_params).with(params)
      expect(cmd).to receive(:connect).with("target", an_instance_of(Hash)).and_return(target_host)
      msg = ChefWorkstation::Text.status.install_chef.verifying
      expect(ChefWorkstation::UI::Terminal).to receive(:spinner).with(msg, { prefix: "[target]" }).and_yield(reporter)
      expect(cmd).to receive(:install).with(reporter)
      msg = "other_msg"
      converge_args = {}
      expect(cmd).to receive(:parse_converge_args).with({ target_host: target_host }, params).and_return([converge_args, msg])
      expect(ChefWorkstation::UI::Terminal).to receive(:spinner).with(msg, { prefix: "[target]" }).and_yield(reporter)
      expect(cmd).to receive(:converge).with(reporter, converge_args)

      cmd.run(params)
    end
  end
end
