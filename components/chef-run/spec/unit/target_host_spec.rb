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
require "ostruct"
require "chef-run/target_host"

RSpec.describe ChefRun::TargetHost do
  let(:host) { "mock://example.com" }
  let(:sudo) { true }
  let(:logger) { nil }
  subject { ChefRun::TargetHost.new(host, sudo: sudo, logger: logger) }

  context "#base_os" do
    before do
      platform_mock = double("platform", linux?: is_linux, family: family, name: "an os")
      allow(subject).to receive(:platform).and_return platform_mock
    end

    context "for a windows os" do
      let(:family) { "windows" }
      let(:is_linux) { false }
      it "reports :windows" do
        expect(subject.base_os).to eq :windows
      end
    end

    context "for a linux os" do
      let(:family) { "debian" }
      let(:is_linux) { true }
      it "reports :linux" do
        expect(subject.base_os).to eq :linux
      end
    end

    context "for an unsupported OS" do
      let(:family) { "other" }
      let(:is_linux) { false }
      it "raises UnsupportedTargetOS" do
        expect { subject.base_os }.to raise_error(ChefRun::TargetHost::UnsupportedTargetOS)
      end
    end
  end

  context "#installed_chef_version" do
    let(:manifest) { :not_found }
    before do
      allow(subject).to receive(:get_chef_version_manifest).and_return manifest
    end

    context "when no version manifest is present" do
      it "raises ChefNotInstalled" do
        expect { subject.installed_chef_version }.to raise_error(ChefRun::TargetHost::ChefNotInstalled)
      end
    end

    context "when version manifest is present" do
      let(:manifest) { { "build_version" => "14.0.1" } }
      it "reports version based on the build_version field" do
        expect(subject.installed_chef_version).to eq Gem::Version.new("14.0.1")
      end
    end
  end

  context "connect!" do
    context "when an Train::UserError occurs" do
      let(:train_connection_mock) { double("train connection") }
      it "raises a ConnectionFailure" do
        allow(train_connection_mock).to receive(:connection).and_raise Train::UserError
        allow(subject).to receive(:train_connection).and_return(train_connection_mock)
        expect { subject.connect! }.to raise_error(ChefRun::TargetHost::ConnectionFailure)
      end
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
        expected_error = ChefRun::TargetHost::RemoteExecutionFailed
        expect { subject.run_command!("invalid") }.to raise_error(expected_error)
      end
    end
  end

  context "#get_chef_version_manifest" do
    let(:manifest_content) { '{"build_version" : "1.2.3"}' }
    let(:expected_manifest_path) do
      {
        windows: "c:\\opscode\\chef\\version-manifest.json",
        linux: "/opt/chef/version-manifest.json"
      }
    end
    let(:base_os) { :unknown }
    before do
      remote_file_mock = double("remote_file", file?: manifest_exists, content: manifest_content)
      backend_mock = double("backend")
      expect(backend_mock).to receive(:file).
        with(expected_manifest_path[base_os]).
        and_return(remote_file_mock)
      allow(subject).to receive(:backend).and_return backend_mock
      allow(subject).to receive(:base_os).and_return base_os
    end

    context "when manifest is missing" do
      let(:manifest_exists) { false }
      context "on windows" do
        let(:base_os) { :windows }
        it "returns :not_found" do
          expect(subject.get_chef_version_manifest).to eq :not_found
        end

      end
      context "on linux" do
        let(:base_os) { :linux }
        it "returns :not_found" do
          expect(subject.get_chef_version_manifest).to eq :not_found
        end
      end
    end

    context "when manifest is present" do
      let(:manifest_exists) { true }
      context "on windows" do
        let(:base_os) { :windows }
        it "should return the parsed manifest" do
          expect(subject.get_chef_version_manifest).to eq({ "build_version" => "1.2.3" })
        end
      end

      context "on linux" do
        let(:base_os) { :linux }
        it "should return the parsed manifest" do
          expect(subject.get_chef_version_manifest).to eq({ "build_version" => "1.2.3" })
        end
      end
    end
  end
end
