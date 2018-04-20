# Copyright:: Copyright (c) 2017 Chef Software Inc.
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
require "chef-workstation/error"
require "chef-workstation/text"
require "chef-workstation/ui/terminal"

RSpec.describe ChefWorkstation::CLI do
  let(:argv) { [] }

  subject(:cli) do
    ChefWorkstation::CLI.new(argv)
  end
  let(:telemetry) { ChefWorkstation::Telemetry }

  context "run" do
    before do
      expect(subject).to receive(:setup_cli)
    end

    it "performs the steps necessary to handle the request and capture telemetry" do
      expect(subject).to receive(:perform_command)
      expect(telemetry).to receive(:timed_capture).
        with(:run, args: []).and_yield
      expect(telemetry).to receive(:send!)
      expect { cli.run }.to raise_error SystemExit
    end

    context "when a known command is supplied" do
      let(:argv) { %w{config show} }

      it "invokes the command" do
        expect(subject).to receive(:have_command?).with("config").and_return(true)
        expect_any_instance_of(ChefWorkstation::Command::Config::Show).to receive(:run)
        expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
      end
    end

    context "when an unknown command is supplied" do
      let(:argv) { %w{unknown} }

      it "raises an error, displays it, and exits non-zero" do
        expect(subject).to receive(:have_command?).with("unknown").and_return(false)
        expect(subject).to receive(:capture_exception_backtrace)
        expect(ChefWorkstation::UI::ErrorPrinter).to receive(:show_error)
        expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end

    context "version flag provided" do
      let(:expected_version_string) { ChefWorkstation::VERSION }
      %w{-v --version version}.each do |flag|
        context "as #{flag}" do
          let(:argv) { [flag] }
          it "shows version and exits 0" do
            expect(ChefWorkstation::UI::Terminal).to receive(:output).with(expected_version_string)
            expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
          end
        end
      end
    end

    context "help handling" do
      context "help command called on a subcommand" do
        let(:argv) { %w{help config} }
        it "passes the help message to the subcommand" do
          expect(cli).to receive(:have_command?).with("config").and_return(true)
          expect_any_instance_of(ChefWorkstation::Command::Base).to receive(:run_with_default_options).with(["--help"]).and_return(0)
          expect { cli.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
        end
      end

      context "help command called with no args" do
        let(:expected_version_string) { ChefWorkstation::Text.commands.base.version_for_help(ChefWorkstation::VERSION) }
        %w{-h --help help}.each do |flag|
          let(:argv) { [flag] }
          it "shows version and top-level help, and exits 0" do
            expect(ChefWorkstation::UI::Terminal).to receive(:output).with(expected_version_string)
            expect { subject.run }.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
          end
        end
      end
    end

  end

  context "#perform_command" do
    context "help command called" do

      let(:argv) { ["help"] }
      it "prints the help text" do
        expect { cli.perform_command }.to output(/Congratulations!.+-c, --config PATH/m).to_terminal
      end
    end

    context "version command called" do
      let(:argv) { ["version"] }
      it "prints the help text" do
        expect { cli.perform_command }.to output("#{ChefWorkstation::VERSION}\n").to_terminal
      end
    end

    context "no command provided" do
      it "prints the help text" do
        expect { cli.perform_command }.to output(/Congratulations!/).to_terminal
      end
    end

    context "when an exception occurs" do
      let(:err) { "A String exception" }
      it "handles it" do
        # and hijack the first call perform_command makes
        # to force an error.
        allow(cli).to receive(:update_args_for_help).and_raise err
        expect(cli).to receive(:handle_perform_error)
        cli.perform_command
      end
    end
  end

  context "#handle_perform_error" do
    it "captures exception data in telemetry, writes backtrace, and re-raises as a WrappedError" do
      original_exception = RuntimeError.new("Test")
      expected_payload = { exception: { id: "RuntimeError",
                                        message: "Test" } }
      expect(telemetry).to receive(:capture).with(:error, expected_payload)
      expect(cli).to receive(:capture_exception_backtrace)
      expect { cli.handle_perform_error(original_exception) }.to raise_error(ChefWorkstation::WrappedError) do |e|
        expect(e.contained_exception.class).to eq RuntimeError
      end

    end
  end
end
