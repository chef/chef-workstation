require "chef-workstation/remote_connection"
require "spec_helper"
RSpec.describe ChefWorkstation::RemoteConnection do
  let(:host) { "example.com" }
  let(:sudo) { true }
  let(:logger) { nil }
  subject(:subject) { ChefWorkstation::RemoteConnection.new(host, sudo: sudo, logger: logger) }

  context "#clean_host_url" do
    it "prefixes a non-prefixed host with ssh://" do
      expect(subject.clean_host_url(host)).to eq "ssh://#{host}"
    end
    it "does not change prefix when ssh is present" do
      original = "ssh://#{host}"
      expect(subject.clean_host_url(original)).to eq original
    end
    it "does not change prefix when winrm is present" do
      original = "winrm://#{host}"
      expect(subject.clean_host_url(original)).to eq original
    end
  end
end
