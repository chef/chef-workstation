require "spec_helper"
require "chef-workstation/action/base"
require "chef-workstation/telemetry"

RSpec.describe ChefWorkstation::Action::Base do
  let(:family) { "windows" }
  let(:connection) do
    p = double("platform", family: family)
    instance_double(ChefWorkstation::TargetHost, platform: p)
  end
  let(:opts) { { connection: connection, other: "something-else" } }
  subject(:action) { ChefWorkstation::Action::Base.new(opts) }

  context "#initialize" do
    it "properly initializes exposed attr readers" do
      expect(action.connection).to eq connection
      expect(action.config).to eq({ other: "something-else" })
    end
  end

  context "#run" do
    it "runs the underlying action, capturing timing via telemetry" do
      expect(ChefWorkstation::Telemetry).to receive(:timed_capture).with(:action, name: "Base").and_yield
      expect(action).to receive(:perform_action)
      action.run
    end

    it "invokes an action handler when actions occur and a handler is provided" do
      @run_action = nil
      @args = nil
      expect(action).to receive(:perform_action) { action.notify(:test_success, "some arg", "some other arg") }
      action.run { |action, args| @run_action = action; @args = args }
      expect(@run_action).to eq :test_success
      expect(@args).to eq ["some arg", "some other arg"]
    end
  end

  shared_examples "check path fetching" do
    [:chef_client, :read_chef_stacktrace].each do |path|
      it "correctly returns path #{path}" do
        expect(action.send(path)).to be_a(String)
      end
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
