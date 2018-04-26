
require "spec_helper"
require "chef-workstation/action/install_chef"

RSpec.describe ChefWorkstation::Action::InstallChef::Base do
  let(:mock_os_name) { "mock" }
  let(:mock_os_family) { "mock" }
  let(:mock_os_release ) { "unknown" }
  let(:mock_opts) do
    {
      name: mock_os_name,
      family: mock_os_family,
      release: mock_os_release,
      arch: "x86_64",
    }
  end
  let(:target_host) do
    ChefWorkstation::TargetHost.new("mock://user1:password1@localhost")
  end

  let(:reporter) do
    ChefWorkstation::MockReporter.new
  end

  subject(:install) do
    ChefWorkstation::Action::InstallChef::Base.new(target_host: target_host,
                                                   reporter: reporter) end
  before do
    target_host.connect!
    target_host.backend.mock_os(mock_opts)
  end

  context "#perform_action" do
    context "when chef is already installed on target" do
      before do
        expect(install).to receive(:already_installed_on_target?).and_return true
      end
      it "takes no action" do
        expect(install).not_to receive(:lookup_artifact)
        install.perform_action
      end
    end

    context "when chef is not already installed on target" do
      before do
        expect(install).to receive(:already_installed_on_target?).and_return false
      end

      context "on windows" do
        let(:mock_os_name) { "Windows_Server" }
        let(:mock_os_family) { "windows" }
        let(:mock_os_releae) { "10.0.1" }

        before do
        end

        it "should invoke perform_local_install" do
          expect(install).to receive(:perform_local_install)
          install.perform_action
        end
      end

      context "on anything else" do
        let(:mock_os_name) { "Ubuntu" }
        let(:mock_os_family) { "debian" }
        it "should invoke perform_local_install" do
          expect(install).to receive(:perform_local_install)
          install.perform_action
        end
      end
    end
  end
  context "#perform_local_install" do
    let(:artifact) { double("artifact") }
    let(:package_url) { "https://chef.io/download/package/here" }
    before do
      allow(artifact).to receive(:url).and_return package_url
    end

    it "performs the steps necessary to perform an installation" do
      expect(install).to receive(:lookup_artifact).and_return artifact
      expect(install).to receive(:download_to_workstation).with(package_url) .and_return "/local/path"
      expect(install).to receive(:upload_to_target).with("/local/path").and_return("/remote/path")
      expect(install).to receive(:install_chef_to_target).with("/remote/path")

      install.perform_local_install
    end
  end
end
