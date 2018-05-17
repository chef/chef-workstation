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
require "chef-run/cli"
require "chef-run/error"
require "chef-run/telemeter"
require "chef-run/ui/terminal"

RSpec.describe ChefRun::CLI do
  let(:argv) { [] }

  subject(:cli) do
    ChefRun::CLI.new(argv)
  end
  let(:telemetry) { ChefRun::Telemeter.instance }

  describe "run" do
    # it "t" do
    #   expect(subject).to receive(:parse_options).with(argv)
    #   subject.run
    # end

    # it "sets up the cli" do
    #   expect(subject).to receive(:setup_cli)
    #   expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    # end
    #
    # # TODO - test for Sender.new.run in thread
    # it "performs the steps necessary to capture telemetry" do
    #   expect(telemetry).to receive(:timed_run_capture).and_yield
    #   expect(telemetry).to receive(:commit)
    #   expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    # end
    #
    # it "calls perform_run" do
    #   expect(subject).to receive(:perform_run)
    #   expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    # end
    #
    # context "perform_run raises WrappedError" do
    #   let(:e) { ChefRun::WrappedError.new(RuntimeError.new("Test"), "host") }
    #
    #   it "prints the error and exits" do
    #     expect(subject).to receive(:perform_run).and_raise(e)
    #     expect(ChefRun::UI::ErrorPrinter).to receive(:show_error).with(e)
    #     expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    #   end
    # end
    #
    # context "perform_run raises SystemExit" do
    #   it "exits with same exit code" do
    #     expect(subject).to receive(:perform_run).and_raise(SystemExit.new(99))
    #     expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(99) }
    #   end
    # end
    #
    # context "perform_run raises any other exception" do
    #   let(:e) { Exception.new("test") }
    #
    #   it "exits with same exit code" do
    #     expect(subject).to receive(:perform_run).and_raise(e)
    #     expect(ChefRun::UI::ErrorPrinter).to receive(:dump_unexpected_error).with(e)
    #     expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(64) }
    #   end
    # end
  end

  describe "#perform_run" do
    it "parses options" do
      expect(subject).to receive(:parse_options).with(argv)
      subject.perform_run
    end

    context "when any error is raised" do
      let(:e) { RuntimeError.new("Test") }
      before do
        allow(subject).to receive(:parse_options).and_raise(e)
      end

      it "calls handle_perform_error" do
        expect(subject).to receive(:handle_perform_error).with(e)
        subject.perform_run
      end
    end

    context "when argv is empty" do
      let(:argv) { [] }
      it "shows the help text" do
        expect(subject).to receive(:show_help)
        subject.perform_run
      end
    end

    context "when help flags are passed" do
      %w{-h --help}.each do |flag|
        context flag do
          let(:argv) { [flag] }
          it "shows the help text" do
            expect(subject).to receive(:show_help)
            subject.perform_run
          end
        end
      end

      %w{-v --version}.each do |flag|
        context flag do
          let(:argv) { [flag] }
          it "shows the help text" do
            expect(subject).to receive(:show_version)
            subject.perform_run
          end
        end
      end
    end

    context "when argv is not empty and no flags" do
      let(:argv) { %w{host resource name} }
      before(:each) do
        allow(subject).to receive(:validate_params)
        allow(subject).to receive(:configure_chef)
        allow(subject).to receive(:generate_temp_cookbook).and_return([:mock_cb, "test"])
        allow(subject).to receive(:run_single_target)
        allow(subject).to receive(:run_multi_target)
        allow_any_instance_of(ChefRun::TargetResolver).to receive(:targets).and_return(["host"])
      end

      it "validate params" do
        expect(subject).to receive(:validate_params)
        subject.perform_run
      end

      it "configure chef" do
        expect(subject).to receive(:configure_chef)
        subject.perform_run
      end

      it "resolve targets" do
        expect_any_instance_of(ChefRun::TargetResolver).to receive(:targets)
        subject.perform_run
      end

      it "generates the temp cookbook" do
        expect(subject).to receive(:generate_temp_cookbook)
        subject.perform_run
      end

      context "when one target host" do
        before do
          allow_any_instance_of(ChefRun::TargetResolver).to receive(:targets).and_return(["host"])
        end

        it "calls run_single_target" do
          expect(subject).to receive(:run_single_target).with("test", "host", :mock_cb)
          subject.perform_run
        end
      end

      context "when one target host" do
        before do
          allow_any_instance_of(ChefRun::TargetResolver).to receive(:targets).and_return(%w{host host2})
        end

        it "calls run_multi_target" do
          expect(subject).to receive(:run_multi_target).with("test", %w{host host2}, :mock_cb)
          subject.perform_run
        end
      end
    end
  end

  describe "#validate_params" do
    OptionValidationError = ChefRun::CLI::OptionValidationError
    it "raises an error if not enough params are specified" do
      params = [
        [],
        %w{one}
      ]
      params.each do |p|
        expect { subject.validate_params(p) }.to raise_error(OptionValidationError) do |e|
          e.id == "CHEFVAL002"
        end
      end
    end

    it "succeeds if the second command is a valid file path" do
      params = %w{target /some/path}
      expect(File).to receive(:exist?).with("/some/path").and_return true
      expect { subject.validate_params(params) }.to_not raise_error
    end

    it "succeeds if the second argument looks like a cookbook name" do
      params = [
        %w{target cb},
        %w{target cb::recipe}
      ]
      params.each do |p|
        expect { subject.validate_params(p) }.to_not raise_error
      end
    end

    it "raises an error if the second argument is neither a valid path or a valid cookbook name" do
      params = %w{target weird%name}
      expect { subject.validate_params(params) }.to raise_error(OptionValidationError) do |e|
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
        expect { subject.validate_params(p) }.to raise_error(OptionValidationError) do |e|
          e.id == "CHEFVAL003"
        end
      end
    end
  end

  describe "#format_properties" do
    it "parses properties into a hash" do
      provided = %w{key1=value key2=1 key3=true key4=FaLsE key5=0777 key6=https://some.website key7=num1and2digit key_8=underscore}
      expected = {
        "key1" => "value",
        "key2" => 1,
        "key3" => true,
        "key4" => false,
        "key5" => "0777",
        "key6" => "https://some.website",
        "key7" => "num1and2digit",
        "key_8" => "underscore"
      }
      expect(subject.format_properties(provided)).to eq(expected)
    end
  end

  describe "#generate_temp_cookbook" do
    let(:tc) { instance_double(ChefRun::TempCookbook) }

    before do
      expect(ChefRun::TempCookbook).to receive(:new).and_return(tc)
    end

    context "when trying to converge a recipe" do
      let(:cli_arguments) { [p] }
      let(:recipe_lookup) { instance_double(ChefRun::RecipeLookup) }
      let(:status_msg) { ChefRun::Text.status.converge.converging_recipe(p) }
      let(:cookbook) { double("cookbook") }
      let(:recipe_path) { "/recipe/path" }

      context "as a path" do
        let(:p) { recipe_path }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return true
          expect(tc).to receive(:from_existing_recipe).with(recipe_path)
          actual1, actual2 = subject.generate_temp_cookbook(cli_arguments)
          expect(actual1).to eq(tc)
          expect(actual2).to eq(status_msg)
        end
      end

      context "as a cookbook name" do
        let(:p) { "cb_name" }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return false
          expect(ChefRun::RecipeLookup).to receive(:new).and_return(recipe_lookup)
          expect(recipe_lookup).to receive(:split).with(p).and_return([p])
          expect(recipe_lookup).to receive(:load_cookbook).with(p).and_return(cookbook)
          expect(recipe_lookup).to receive(:find_recipe).with(cookbook, nil).and_return(recipe_path)
          expect(tc).to receive(:from_existing_recipe).with(recipe_path)
          actual1, actual2 = subject.generate_temp_cookbook(cli_arguments)
          expect(actual1).to eq(tc)
          expect(actual2).to eq(status_msg)
        end
      end

      context "as a cookbook and recipe name" do
        let(:cookbook_name) { "cb_name" }
        let(:recipe_name) { "recipe_name" }
        let(:p) { cookbook_name + "::" + recipe_name }
        it "returns the recipe path" do
          expect(File).to receive(:file?).with(p).and_return false
          expect(ChefRun::RecipeLookup).to receive(:new).and_return(recipe_lookup)
          expect(recipe_lookup).to receive(:split).with(p).and_return([cookbook_name, recipe_name])
          expect(recipe_lookup).to receive(:load_cookbook).with(cookbook_name).and_return(cookbook)
          expect(recipe_lookup).to receive(:find_recipe).with(cookbook, recipe_name).and_return(recipe_path)
          expect(tc).to receive(:from_existing_recipe).with(recipe_path)
          actual1, actual2 = subject.generate_temp_cookbook(cli_arguments)
          expect(actual1).to eq(tc)
          expect(actual2).to eq(status_msg)
        end
      end

    end

    context "when trying to converge a resource" do
      let(:cli_arguments) { %w{directory foo prop1=val1 prop2=val2} }
      it "returns the resource information" do
        expect(tc).to receive(:from_resource).with("directory", "foo", { "prop1" => "val1", "prop2" => "val2" })
        actual1, actual2 = subject.generate_temp_cookbook(cli_arguments)
        expect(actual1).to eq(tc)
        msg = ChefRun::Text.status.converge.converging_resource("directory[foo]")
        expect(actual2).to eq(msg)
      end
    end
  end

  describe "#configure_chef" do
    it "sets ChefConfig.ogger to ChefRun.log" do
      subject.configure_chef
      expect(ChefConfig.logger).to eq(ChefRun::Log)
    end

    it "initializes Chef::Log" do
      expect(Chef::Log).to receive(:init).with(ChefRun::Log)
      subject.configure_chef
    end

    it "sets ChefConfig.ogger to ChefRun.log" do
      subject.configure_chef
      expect(ChefConfig.logger).to eq(ChefRun::Log)
    end
  end

  describe "#setup_cli" do
    it "initializes ChefRun::UI::Terminal" do
      expect(ChefRun::UI::Terminal).to receive(:init).with($stdout)
      subject.setup_cli
    end

    it "creates config directory tree" do
      expect(ChefRun::Config).to receive(:create_directory_tree)
      subject.setup_cli
    end

    it "creates loads config" do
      expect(ChefRun::Config).to receive(:load)
      subject.setup_cli
    end

    it "sets up logging" do
      allow(ChefRun::Config).to receive_message_chain(:log, :location).and_return("test")
      allow(ChefRun::Config).to receive_message_chain(:log, :level).and_return("test")
      expect(ChefRun::Log).to receive(:setup).with("test", :test)
      expect(ChefRun::Log).to receive(:info).with("Initialized logger")
      subject.setup_cli
    end

    context "when using default config location and config does not exist" do
      it "sets up the workstation" do
        allow(ChefRun::Config).to receive(:using_default_location?).and_return(true)
        allow(ChefRun::Config).to receive(:exist?).and_return(false)
        expect(subject).to receive(:setup_workstation)
        subject.setup_cli
      end
    end
  end

  describe "#run_single_target" do
    let(:installer) { instance_double(ChefRun::Action::InstallChef::Linux) }
    let(:converger) { instance_double(ChefRun::Action::ConvergeTarget) }
    let(:reporter) { instance_double(ChefRun::StatusReporter) }
    let(:host1) { ChefRun::TargetHost.new("ssh://host1") }
    it "connects, installs chef on and converges the target" do
      expect(subject).to receive(:connect_target).with(host1)
      expect(subject).to receive(:install).with(host1, anything())
      expect(subject).to receive(:converge)
      subject.run_single_target("", host1, {})
    end
  end

  describe "#run_multi_target" do
    let(:reporter) { instance_double(ChefRun::StatusReporter) }
    let(:host1) { ChefRun::TargetHost.new("ssh://host1") }
    let(:host2) { ChefRun::TargetHost.new("ssh://host2") }
    it "connects, installs chef on and converges the targets" do
      expect(subject).to receive(:connect_target).with(host1, anything())
      expect(subject).to receive(:connect_target).with(host2, anything())
      expect(subject).to receive(:install).with(host1, anything())
      expect(subject).to receive(:install).with(host2, anything())
      expect(subject).to receive(:converge).exactly(2).times
      subject.run_multi_target("", [host1, host2], {})
    end
  end
end
