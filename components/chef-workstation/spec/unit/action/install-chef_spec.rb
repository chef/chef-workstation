
require "spec_helper"
require "remote_connection_mock"
require "chef-workstation/action/install-chef"
RSpec.describe ChefWorkstation::Action::InstallChef do

  let(:osname) { "linux" }
  let(:osarch) { "x86_64" }
  let(:osversion) { "14.04" }
  let(:is_linux) { true }
  let(:conn) { ChefWorkstation::RemoteConnectionMock.new(osname, osversion, osarch, is_linux) }
  let(:action_options) { { sudo: true } }
  subject(:install) { ChefWorkstation::Action::InstallChef.new(action_options.merge(connection: conn)) }

  context "#perform_action" do
    let(:artifact) { double("artifact") }
    let(:package_url) { "https://chef.io/download/package/here" }
    before do
      allow(artifact).to receive(:url).and_return package_url
    end

    it "raises if target platform is not supported" do
      expect(install).to receive(:verify_target_platform!).and_raise("Nope")
      expect { install.perform_action }.to raise_error("Nope")
    end

    it "stops if chef is already installed on target" do
      expect(install).to receive(:verify_target_platform!)
      expect(install).to receive(:already_installed_on_target?).and_return true
      expect(install).not_to receive(:lookup_artifact)
      install.perform_action
    end
    it "performs the steps necessary to perform an installation" do
      expect(install).to receive(:verify_target_platform!)
      expect(install).to receive(:already_installed_on_target?).and_return false
      expect(install).to receive(:lookup_artifact).and_return artifact
      expect(install).to receive(:download_to_workstation).with(package_url) .and_return "/local/path"
      expect(install).to receive(:upload_to_target).with("/local/path").and_return("/remote/path")
      expect(install).to receive(:install_chef_to_target).with("/remote/path")

      install.perform_action
    end
  end

  context "verify_target_platform!" do
    context "on unsupported platforms" do
      let(:is_linux) { false }
      let(:osname) { "SunOS" }
      let(:errors) { ChefWorkstation::Action::Errors }
      it "raises UnsupportedTargetOS" do
        expect { install.verify_target_platform! }.to raise_error do |e|
          expect(e.class).to eq ChefWorkstation::Action::Errors::UnsupportedTargetOS
          expect(e.params).to eq([osname])
        end
      end

    end
    context "on supported platforms" do
      let(:is_linux) { true }
      it "runs without error" do
        expect(install.verify_target_platform!).to eq :ok
      end
    end
  end
end
