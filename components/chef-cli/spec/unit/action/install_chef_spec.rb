require "spec_helper"
require "chef-cli/action/install_chef"

RSpec.describe ChefCLI::Action::InstallChef do
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
    ChefCLI::TargetHost.new("mock://user1:password1@localhost")
  end

  subject(:installer) do
    ChefCLI::Action::InstallChef
  end

  before do
    target_host.connect!
    target_host.backend.mock_os(mock_opts)
  end

  context ".instance_for_target" do
    context "windows target" do
      let(:mock_os_name) { "Windows_Server" }
      let(:mock_os_family) { "windows" }
      let(:mock_os_release) { "10.0.0" }

      it "should return a InstallChef::Windows instance" do
        inst = installer.instance_for_target(target_host)
        expect(inst).to be_a installer::Windows
      end
    end

    context "linux target" do
      let(:mock_os_name) { "ubuntu" }
      let(:mock_os_family) { "debian" }
      let(:mock_os_release) { "16.04" }

      it "should return a InstallChef::Linux instance" do
        inst = installer.instance_for_target(target_host)
        expect(inst).to be_a installer::Linux
      end
    end
  end
end
