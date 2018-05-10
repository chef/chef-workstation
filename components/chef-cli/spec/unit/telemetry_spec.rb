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
require "chef-cli/telemetry"

RSpec.describe ChefCLI::Telemetry do
  subject(:telemetry) { ChefCLI::Telemetry }
  let(:dev_mode) { true }
  let(:config) { double("config") }

  before do
    allow(config).to receive(:dev).and_return dev_mode
    allow(ChefCLI::Config).to receive(:telemetry).and_return config
    allow(telemetry.instance).to receive(:host_platform).and_return "linux"
  end

  after do
    # Force the send queue to empty
    telemetry.send!
  end

  context "#send!" do
    xit "should send the pending events out for further processing" do
    end

    it "should clear the queue of any pending events" do
      telemetry.send!
      expect(telemetry.pending_event_count).to eq 0
    end
  end

  context "#timed_capture" do
    let(:runner) { double("capture_test") }
    it "executes the requested thing" do
      expect(runner).to receive(:do_it)
      telemetry.timed_capture(:do_it_test) do
        runner.do_it
      end
    end

    it "captures an event containing the run duration" do
      expect(telemetry.pending_event_count).to eq 0
      telemetry.timed_capture(:do_it_test) { :ok }
      expect(telemetry.last_event[:data][:duration]).to be_a Float
      expect(telemetry.pending_event_count).to eq 1
    end
  end

  context "#make_event_payload" do
    context "when event is ':run'" do
      it "adds expected properties" do
        payload = telemetry.make_event_payload(:run, { hello: "world" })
        expect(payload[:event]).to eq :run
        expect(payload[:data]).to eq({ hello: "world" })
        props = payload[:properties]
        expect(props[:usage_type]).to eq "dev"
        expect(props[:host_platform]).to eq "linux"
        expect(props[:version]).to eq ChefCLI::VERSION
        expect(props[:time]).to_not eq nil
      end
    end

    context "when event is not ':run'" do
      it "includes only the 'time' property" do
        payload = telemetry.make_event_payload(:install_chef, { hello: "world" })
        expect(payload[:data]).to eq({ hello: "world" })
        expect(payload[:properties][:time]).to_not eq nil
        expect(payload[:properties][:usage_type]).to eq nil
      end
    end
  end
end
