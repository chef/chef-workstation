require "spec_helper"
require "ostruct"
require "chef-workstation/remote_connection"

RSpec.describe ChefWorkstation::RemoteConnection do
  let(:host) { "example.com" }
  let(:sudo) { true }
  let(:logger) { nil }
  subject(:subject) { ChefWorkstation::RemoteConnection.new(host, sudo: sudo, logger: logger) }

  context "#maybe_add_default_scheme" do
    it "prefixes a non-prefixed host with ssh://" do
      expect(subject.maybe_add_default_scheme(host)).to eq "ssh://#{host}"
    end
    it "does not change prefix when ssh is present" do
      original = "ssh://#{host}"
      expect(subject.maybe_add_default_scheme(original)).to eq original
    end
    it "does not change prefix when winrm is present" do
      original = "winrm://#{host}"
      expect(subject.maybe_add_default_scheme(original)).to eq original
    end
  end

  context "#run_command!" do
    let(:backend) { double("backend") }
    let(:exit_status) { 0 }
    let(:result) { RemoteExecResult.new(exit_status, "", "an error occurred") }

    before do
      allow(subject).to receive(:backend).and_return(backend)
      allow(backend).to receive(:run_command).and_return(result)
    end
    context "when no error occurs" do
      let(:exit_status) { 0 }
      it "returns the result" do
        expect(subject.run_command!("valid")).to eq result
      end
    end

    context "when an error occurs" do
      let(:exit_status) { 1 }
      it "raises a RemoteExecutionFailed error" do
        expect { subject.run_command!("invalid") }.to raise_error ChefWorkstation::RemoteConnection::RemoteExecutionFailed
      end
    end
  end
end
