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
require "chef-run/telemeter"

RSpec.describe ChefRun::Telemeter do
  subject { ChefRun::Telemeter.instance }
  let(:host_platform) { "linux" }

  before do
    allow(subject).to receive(:host_platform).and_return host_platform
  end

  context "#commit" do
    context "when telemetry is enabled" do
      before do
        allow(subject).to receive(:enabled?).and_return true
      end

      it "writes events out and clears the queue" do
        subject.capture(:test)
        expect(subject.pending_event_count).to eq 1
        expect(subject).to receive(:convert_events_to_session)
        expect(subject).to receive(:write_session)

        subject.commit
        expect(subject.pending_event_count).to eq 0
      end
    end

    context "when telemetry is disabled" do
      before do
        allow(subject).to receive(:enabled?).and_return false
      end
      it "does not write any events and clears the queue" do
        subject.capture(:test)
        expect(subject.pending_event_count).to eq 1
        expect(subject).to_not receive(:convert_events_to_session)

        subject.commit
        expect(subject.pending_event_count).to eq 0
      end
    end
  end

  context "#timed_action_capture" do
    context "when a valid target_host is present" do
      it "invokes timed_capture with action and valid target data" do
        target = instance_double("TargetHost",
                                 base_os: "windows",
                                 version: "10.0.0",
                                 architecture: "x86_64",
                                 hostname: "My_Host",
                                 transport_type: "winrm")
        action = instance_double("Action::Base", name: "test_action",
                                                 target_host: target)
        expected_data = {
          action: "test_action",
          target: {
            platform: {
              name: "windows",
              version: "10.0.0",
              architecture: "x86_64"
            },
            hostname_sha1: Digest::SHA1.hexdigest("my_host"),
            transport_type: "winrm"
          }
        }
        expect(subject).to receive(:timed_capture).with(:action, expected_data)
        subject.timed_action_capture(action) { :ok }
      end

      context "when a valid target_host is not present" do
        it "invokes timed_capture with empty target values" do
          expected_data = { action: "Base", target: { platform: {},
                                                      hostname_sha1: nil,
                                                      transport_type: nil } }
          expect(subject).to receive(:timed_capture).
            with(:action, expected_data)
          subject.timed_action_capture(
            ChefRun::Action::Base.new(target_host: nil)
          ) { :ok }
        end
      end
    end
  end

  context "::enabled?" do
    let(:enabled_flag) { false }
    let(:config) { double("config") }
    before do
      allow(ChefRun::Config).to receive(:telemetry).and_return(config)
      allow(config).to receive(:enable).and_return(enabled_flag)
    end

    context "when config value is enabled" do
      let(:enabled_flag) { true }
      context "and CHEF_TELEMETRY_OPT_OUT is not present in env vars" do
        it "returns false" do
          ENV.delete("CHEF_TELEMETRY_OPT_OUT")
          expect(subject.enabled?).to eq true
        end
      end
      context "and CHEF_TELEMETRY_OPT_OUT is present in env vars" do
        it "returns false" do
          ENV["CHEF_TELEMETRY_OPT_OUT"] = ""
          expect(subject.enabled?).to eq false
        end
      end
    end

    context "when config value is disabled" do
      let(:enabled_flag) { false }
      it "returns false" do
        expect(subject.enabled?).to eq false
      end
    end
  end

  context "#timed_run_capture" do
    it "invokes timed_capture with run data" do
      expected_data = { arguments: [ "arg1" ] }
      expect(subject).to receive(:timed_capture).
        with(:run, expected_data)
      subject.timed_run_capture(["arg1"])
    end
  end

  context "#timed_capture" do
    let(:runner) { double("capture_test") }
    before do
      expect(subject.pending_event_count).to eq 0
    end

    it "runs the requested thing and invokes #capture with duration" do
      expect(runner).to receive(:do_it)
      expect(subject).to receive(:capture) do |name, data|
        expect(name).to eq(:do_it_test)
        expect(data[:duration]).to be > 0.0
      end
      subject.timed_capture(:do_it_test) do
        runner.do_it
      end
    end
  end

  context "#capture" do
    before do
      expect(subject.pending_event_count).to eq 0
    end
    it "adds the captured event to the session" do
      subject.capture(:test, {})
      expect(subject.pending_event_count) == 1
    end
  end

  context "#make_event_payload" do
    before do
      allow(subject).to receive(:installation_id).and_return "0000"
    end

    it "adds expected properties" do
      payload = subject.make_event_payload(:run, { hello: "world" })
      expected_payload = {
        event: :run,
        properties: {
          installation_id: "0000",
          run_timestamp: subject.run_timestamp,
          host_platform: host_platform,
          event_data:  { hello: "world" }
        }
      }
      expect(payload).to eq expected_payload
    end
  end
end
