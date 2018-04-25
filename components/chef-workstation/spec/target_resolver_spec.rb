require "spec_helper"
require "chef-workstation/target_resolver"

RSpec.describe ChefWorkstation::TargetResolver do
  let(:target_string) { "" }
  subject { ChefWorkstation::TargetResolver.new(target_string, {}) }

  context "#targets" do
    context "when no target is provided" do
      let(:target_string) { "" }
      it "returns an empty array" do
        expect(subject.targets).to eq []
      end
    end

    context "when a single target is provided" do
      let(:target_string) { "ssh://localhost" }
      it "returns any array with one target" do
        actual_targets = subject.targets
        expect(actual_targets[0].config[:host]).to eq "localhost"
      end
    end

    context "when a comma-separated list of targets is provided" do
      let(:target_string) { "ssh://node1.example.com,winrm://node2.example.com" }
      it "returns an array with correct RemoteConnection instances" do
        actual_targets = subject.targets
        expect(actual_targets[0].config[:host]).to eq "node1.example.com"
        expect(actual_targets[1].config[:host]).to eq "node2.example.com"
      end
    end
  end
end
