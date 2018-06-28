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
require "chef-run/telemeter/sender"
require "chef-run/config"

RSpec.describe ChefRun::Telemeter::Sender do
  let(:session_files) { %w{file1 file2} }
  let(:enabled_flag) { true }
  let(:dev_mode) { false }
  let(:config) { double("config") }

  let(:subject) { ChefRun::Telemeter::Sender.new(session_files) }

  before do
    allow(config).to receive(:dev).and_return dev_mode
    allow(ChefRun::Config).to receive(:telemetry).and_return config
    allow(ChefRun::Telemeter).to receive(:enabled?).and_return enabled_flag
    # Ensure this is not set for each test:
    ENV.delete("CHEF_TELEMETRY_ENDPOINT")
  end

  describe "::start_upload_thread" do
    let(:sender_mock) { instance_double(ChefRun::Telemeter::Sender) }
    it "spawns a thread to run the send" do
      expect(ChefRun::Telemeter::Sender).to receive(:find_session_files).and_return session_files
      expect(ChefRun::Telemeter::Sender).to receive(:new).with(session_files).and_return sender_mock
      expect(sender_mock).to receive(:run)
      expect(::Thread).to receive(:new).and_yield
      ChefRun::Telemeter::Sender.start_upload_thread
    end
  end

  describe "#run" do
    before do
      expect(subject).to receive(:session_files).and_return session_files
    end

    context "when telemetry is disabled" do
      let(:enabled_flag) { false }
      it "deletes session files without sending" do
        expect(FileUtils).to receive(:rm_rf).with("file1")
        expect(FileUtils).to receive(:rm_rf).with("file2")
        expect(FileUtils).to receive(:rm_rf).with(ChefRun::Config.telemetry_session_file)
        expect(subject).to_not receive(:process_session)
        subject.run
      end
    end

    context "when telemetry is enabled" do
      context "and telemetry dev mode is true" do
        let(:dev_mode) { true }
        let(:session_files) { [] } # Ensure we don't send anything without mocking :allthecalls:
        context "and a custom telemetry endpoint is not set" do
          it "configures the environment to submit to the Acceptance telemetry endpoint" do
            subject.run
            expect(ENV["CHEF_TELEMETRY_ENDPOINT"]).to eq "https://telemetry-acceptance.chef.io"
          end
        end

        context "and a custom telemetry endpoint is already set" do
          before do
            ENV["CHEF_TELEMETRY_ENDPOINT"] = "https://localhost"
          end
          it "should not overwrite the custom value" do
            subject.run
            expect(ENV["CHEF_TELEMETRY_ENDPOINT"]).to eq "https://localhost"
          end
        end
      end

      it "submits the session capture for each session file found" do
        expect(subject).to receive(:process_session).with("file1")
        expect(subject).to receive(:process_session).with("file2")
        expect(FileUtils).to receive(:rm_rf).with(ChefRun::Config.telemetry_session_file)
        subject.run
      end
    end

    context "when an error occurrs" do
      it "logs it" do
        allow(config).to receive(:enabled?).and_raise("Failed")
        expect(ChefRun::Log).to receive(:fatal)
        subject.run
      end
    end
  end

  describe "::find_session_files" do
    it "finds all telemetry-payload-*.yml files in the telemetry directory" do
      expect(ChefRun::Config).to receive(:telemetry_path).and_return("/tmp")
      expect(Dir).to receive(:glob).with("/tmp/telemetry-payload-*.yml").and_return []
      ChefRun::Telemeter::Sender.find_session_files
    end
  end

  describe "process_session" do
    it "loads the sesion and submits it" do
      expect(subject).to receive(:load_and_clear_session).with("file1").and_return({ "version" => "1.0.0", "entries" => [] })
      expect(subject).to receive(:submit_session).with({ "version" => "1.0.0", "entries" => [] })
      subject.process_session("file1")
    end
  end

  describe "submit_session" do
    let(:telemetry) { instance_double("telemetry") }
    it "removes the telemetry session file and starts a new session, then submits each entry in the session" do
      expect(ChefRun::Config).to receive(:telemetry_session_file).and_return("/tmp/SESSION_ID")
      expect(FileUtils).to receive(:rm_rf).with("/tmp/SESSION_ID")
      expect(Telemetry).to receive(:new).and_return telemetry
      expect(subject).to receive(:submit_entry).with(telemetry, { "event" => "action1" }, 1, 2)
      expect(subject).to receive(:submit_entry).with(telemetry, { "event" => "action2" }, 2, 2)
      subject.submit_session( { "version" => "1.0.0",
                                "entries" => [ { "event" => "action1" }, { "event" => "action2" } ] } )
    end
  end

  describe "submit_entry" do
    let(:telemetry) { instance_double("telemetry") }
    it "submits the entry to telemetry" do
      expect(telemetry).to receive(:deliver).with("test" => "this")
      subject.submit_entry(telemetry, { "test" => "this" }, 1, 1)
    end
  end
end
