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
require "chef-run/action/install_chef"

RSpec.describe ChefRun::Action::InstallChef do
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
    ChefRun::TargetHost.new("mock://user1:password1@localhost")
  end

  subject(:installer) do
    ChefRun::Action::InstallChef
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
