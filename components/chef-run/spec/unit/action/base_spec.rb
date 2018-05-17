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
require "chef-run/action/base"
require "chef-run/telemeter"
require "chef-run/target_host"

RSpec.describe ChefRun::Action::Base do
  let(:family) { "windows" }
  let(:target_host) do
    p = double("platform", family: family)
    instance_double(ChefRun::TargetHost, platform: p)
  end
  let(:opts) do
    { target_host: target_host,
      other: "something-else" } end
  subject(:action) { ChefRun::Action::Base.new(opts) }

  context "#initialize" do
    it "properly initializes exposed attr readers" do
      expect(action.target_host).to eq target_host
      expect(action.config).to eq({ other: "something-else" })
    end
  end

  context "#run" do
    it "runs the underlying action, capturing timing via telemetry" do
      expect(ChefRun::Telemeter).to receive(:timed_action_capture).with(subject).and_yield
      expect(action).to receive(:perform_action)
      action.run
    end

    it "invokes an action handler when actions occur and a handler is provided" do
      @run_action = nil
      @args = nil
      expect(ChefRun::Telemeter).to receive(:timed_action_capture).with(subject).and_yield
      expect(action).to receive(:perform_action) { action.notify(:test_success, "some arg", "some other arg") }
      action.run { |action, args| @run_action = action; @args = args }
      expect(@run_action).to eq :test_success
      expect(@args).to eq ["some arg", "some other arg"]
    end
  end

  shared_examples "check path fetching" do
    [:chef_client, :cache_path, :read_chef_report, :delete_chef_report, :tempdir, :mktemp, :delete_folder].each do |path|
      it "correctly returns path #{path}" do
        expect(action.send(path)).to be_a(String)
      end
    end

    it "correctly returns chef run string" do
      expect(action.run_chef(nil, nil, nil)).to be_a(String)
    end
  end

  describe "when connecting to a windows target" do
    include_examples "check path fetching"
  end

  describe "when connecting to a non-windows target" do
    let(:family) { "linux" }
    include_examples "check path fetching"
  end

end
