require "spec_helper"
require "chef-workstation/action/base"
require "chef-workstation/telemetry"

RSpec.describe ChefWorkstation::Action::Base do
  let(:opts) { { reporter: "test-reporter", connection: "test-connection", other: "something-else" }}
  subject(:action) { ChefWorkstation::Action::Base.new(opts) }

  context "#initialize" do
    it "properly initializes exposed attribute readers" do
      expect(action.reporter).to eq "test-reporter"
      expect(action.connection).to eq "test-connection"
      expect(action.config).to eq({ other: "something-else" })
    end
  end
  context "#run" do
     it "runs the underlying action, capturing timing via telemetry" do
       expect(ChefWorkstation::Telemetry).to receive(:timed_capture).with(:action, name: "Base").and_yield
       expect(action).to receive(:perform_action)
       action.run
     end
  end


end


