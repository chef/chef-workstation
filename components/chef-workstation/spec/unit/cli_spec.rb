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
require "chef-workstation/cli"
require "chef-workstation/telemetry"

RSpec.describe ChefWorkstation::Cli do
  let(:argv) { [] }

  subject(:cli) do
    ChefWorkstation::Cli.new(argv)
  end
  let(:telemetry) { ChefWorkstation::Telemetry }

  context "run" do
    it "performs the steps necessary to handle the request and capture telemetry" do
      expect(subject).to receive(:parse_cli_options!)
      expect(subject).to receive(:initialize_config)
      expect(subject).to receive(:perform_command)
      expect(telemetry).to receive(:timed_capture).
        with(:run,
             command: nil,
             sub: nil, args: [],
             opts: cli.instance_variable_get(:@cli_options).to_h).and_yield
      expect(telemetry).to receive(:send!)
      cli.run
    end
  end

  context "#perform_command" do
    context "version set in cli_options" do
      let(:version_message) { "Version #{ChefWorkstation::VERSION}" }

      before do
        cli.cli_options.version = true
      end

      it "prints version" do
        expect(STDOUT).to receive(:puts).with(version_message)
        cli.perform_command
      end
    end

    context "help set in cli_options" do
      let(:version_message) { "Version #{ChefWorkstation::VERSION}" }

      before do
        cli.cli_options.help = true
      end

      it "prints banner" do
        expect(STDOUT).to receive(:puts).with(cli.instance_variable_get :@parser)
        cli.perform_command
      end
    end

    context "no cli_options" do
      it "prints the short_banner" do
        expect(STDOUT).to receive(:puts).with(cli.short_banner)
        cli.perform_command
      end
    end
  end

  context "parse_cli_options!" do
    context "short options" do
      context "given -v" do
        let(:argv) { %w{-v} }

        it "should set cli_options.version true" do
          cli.parse_cli_options!
          expect(cli.cli_options.version).to eq(true)
        end
      end

      context "given -h" do
        let(:argv) { %w{-h} }

        it "should set cli_options.help true" do
          cli.parse_cli_options!
          expect(cli.cli_options.help).to eq(true)
        end
      end
    end

    context "long options" do
      context "given --version" do
        let(:argv) { %w{--version} }

        it "should set cli_options.version true" do
          cli.parse_cli_options!
          expect(cli.cli_options.version).to eq(true)
        end
      end

      context "given --help" do
        let(:argv) { %w{--help} }

        it "should set cli_options.help true" do
          cli.parse_cli_options!
          expect(cli.cli_options.help).to eq(true)
        end
      end
    end

    context "given 'help'" do
      let(:argv) { %w{help} }

      it "should set cli_options.help true" do
        cli.parse_cli_options!
        expect(cli.cli_options.help).to eq(true)
      end
    end

    context "given an invalid option" do
      let(:argv) { %w{--invalid} }

      it "should raise an error" do
        expect { cli.parse_cli_options! }
          .to raise_error(OptionParser::InvalidOption)
      end
    end
  end

  context "short_banner" do
    it "should return a short banner" do
      expect(cli.short_banner).to eq("Usage:  chef COMMAND [options...]")
    end
  end

  context "banner" do
    # We are testing the usage text becuase ux has sugned off on this wording.
    it "should return a banner" do
      expect(cli.banner).to eq <<EOM
Usage:  chef COMMAND [options...]

Congratulations! You are using chef: your gateway
to managing everything from a single node to an entire Chef
infrastructure.

Required Arguments:
    COMMAND - the command to execute, one of:
       help - show command help

Flags:
EOM
    end
  end

  context "when a command is supplied" do
    let(:argv) { %w{config show} }

    it "calls the config show" do
      expect(cli).to receive(:parse_cli_options!)
      expect(cli).to receive(:initialize_config)
      expect_any_instance_of(ChefWorkstation::Command::ShowConfig).to receive(:run)
      cli.run
    end
  end

end
