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
require "chef-run/action/converge_target"
require "chef-run/target_host"
require "chef-run/errors/ccr_failure_mapper"
require "chef-run/temp_cookbook"

RSpec.describe ChefRun::Action::ConvergeTarget do
  let(:archive) { "archive.tgz" }
  let(:target_host) do
    p = double("platform", family: "windows")
    instance_double(ChefRun::TargetHost, platform: p)
  end
  let(:local_policy_path) { "/local/policy/path/archive.tgz" }
  let(:opts) { { target_host: target_host, local_policy_path: local_policy_path } }
  subject(:action) { ChefRun::Action::ConvergeTarget.new(opts) }

  describe "#create_remote_policy" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_archive) { File.join(remote_folder, File.basename(archive)) }

    before do
    end

    it "pushes it to the remote machine" do
      expect(target_host).to receive(:upload_file).with(local_policy_path, remote_archive)
      expect(subject.create_remote_policy(local_policy_path, remote_folder)).to eq(remote_archive)
    end

    it "raises an error if the upload fails" do
      expect(target_host).to receive(:upload_file).with(local_policy_path, remote_archive).and_raise("foo")
      err = ChefRun::Action::ConvergeTarget::PolicyUploadFailed
      expect { subject.create_remote_policy(local_policy_path, remote_folder) }.to raise_error(err)
    end
  end

  describe "#create_remote_config" do

    @closed = false # tempfile close indicator
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_config) { "#{remote_folder}/workstation.rb" }
    # TODO - mock this, I think we're leaving things behind in /tmp in test runs.
    let!(:local_tempfile) { Tempfile.new }

    it "pushes it to the remote machine" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config)
      expect(subject.create_remote_config(remote_folder)).to eq(remote_config)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end

    it "raises an error if the upload fails" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config).and_raise("foo")
      err = ChefRun::Action::ConvergeTarget::ConfigUploadFailed
      expect { subject.create_remote_config(remote_folder) }.to raise_error(err)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end

    describe "when data_collector is set in config" do
      before do
        ChefRun::Config.data_collector.url = "dc.url"
        ChefRun::Config.data_collector.token = "dc.token"
      end

      after do
        ChefRun::Config.reset
      end

      it "creates a config file with data collector config values" do
        expect(Tempfile).to receive(:new).and_return(local_tempfile)
        expect(local_tempfile).to receive(:write).with(<<~EOM
          local_mode true
          color false
          cache_path "\#{ENV['APPDATA']}/chef-workstation"
          chef_repo_path "\#{ENV['APPDATA']}/chef-workstation"
          require_relative "reporter"
          reporter = ChefRun::Reporter.new
          report_handlers << reporter
          exception_handlers << reporter
          data_collector.server_url "dc.url"
          data_collector.token "dc.token"
          data_collector.mode :solo
          data_collector.organization "Chef Workstation"
        EOM
        )
        expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config)
        expect(subject.create_remote_config(remote_folder)).to eq(remote_config)
      # ensure the tempfile is deleted locally
        expect(local_tempfile.closed?).to eq(true)
      end
    end

    describe "when data_collector is not set" do
      before do
        ChefRun::Config.data_collector.url = nil
        ChefRun::Config.data_collector.token = nil
      end

      it "creates a config file without data collector config values" do
        expect(Tempfile).to receive(:new).and_return(local_tempfile)
        expect(local_tempfile).to receive(:write).with(<<~EOM
          local_mode true
          color false
          cache_path "\#{ENV['APPDATA']}/chef-workstation"
          chef_repo_path "\#{ENV['APPDATA']}/chef-workstation"
          require_relative "reporter"
          reporter = ChefRun::Reporter.new
          report_handlers << reporter
          exception_handlers << reporter
        EOM
        )
        expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config)
        expect(subject.create_remote_config(remote_folder)).to eq(remote_config)
        # ensure the tempfile is deleted locally
        expect(local_tempfile.closed?).to eq(true)
      end
    end
  end

  describe "#create_remote_handler" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_reporter) { "#{remote_folder}/reporter.rb" }
    let!(:local_tempfile) { Tempfile.new }

    it "pushes it to the remote machine" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_reporter)
      expect(subject.create_remote_handler(remote_folder)).to eq(remote_reporter)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end

    it "raises an error if the upload fails" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_reporter).and_raise("foo")
      err = ChefRun::Action::ConvergeTarget::HandlerUploadFailed
      expect { subject.create_remote_handler(remote_folder) }.to raise_error(err)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end
  end

  describe "#upload_trusted_certs" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_tcd) { File.join(remote_folder, "trusted_certs") }
    let(:tmpdir) { Dir.mktmpdir }
    let(:certs_dir) { File.join(tmpdir, "weird/glob/chars[/") }

    before do
      ChefRun::Config.chef.trusted_certs_dir = certs_dir
      FileUtils.mkdir_p(certs_dir)
    end

    after do
      ChefRun::Config.reset
      FileUtils.remove_entry tmpdir
    end

    context "when there are local certificates" do
      let!(:cert1) { FileUtils.touch(File.join(certs_dir, "1.crt"))[0] }
      let!(:cert2) { FileUtils.touch(File.join(certs_dir, "2.pem"))[0] }

      it "uploads the local certs" do
        expect(target_host).to receive(:run_command).with("#{subject.mkdir} #{remote_tcd}", true)
        expect(target_host).to receive(:upload_file).with(cert1, File.join(remote_tcd, File.basename(cert1)))
        expect(target_host).to receive(:upload_file).with(cert2, File.join(remote_tcd, File.basename(cert2)))
        subject.upload_trusted_certs(remote_folder)
      end
    end

    context "when there are no local certificates" do
      it "does not upload any certs" do
        expect(target_host).to_not receive(:run_command)
        expect(target_host).to_not receive(:upload_file)
        subject.upload_trusted_certs(remote_folder)
      end
    end

  end

  describe "#perform_action" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_archive) { File.join(remote_folder, File.basename(archive)) }
    let(:remote_config) { "#{remote_folder}/workstation.rb" }
    let(:remote_handler) { "#{remote_folder}/reporter.rb" }
    let(:tmpdir) { double("tmpdir", exit_status: 0, stdout: remote_folder) }
    before do
      expect(target_host).to receive(:run_command!).with(subject.mktemp, true).and_return(tmpdir)
    end
    let(:result) { double("command result", exit_status: 0, stdout: "") }

    it "runs the converge and reports back success" do
      expect(action).to receive(:create_remote_policy).with(local_policy_path, remote_folder).and_return(remote_archive)
      expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
      expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
      expect(action).to receive(:upload_trusted_certs).with(remote_folder)
      expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
      expect(target_host).to receive(:run_command!)
        .with("#{subject.delete_folder} #{remote_folder}")
        .and_return(result)
      [:running_chef, :success].each do |n|
        expect(action).to receive(:notify).with(n)
      end
      subject.perform_action
    end

    context "when chef schedules restart" do
      let(:result) { double("command result", exit_status: 35) }

      it "runs the converge and reports back reboot" do
        expect(action).to receive(:create_remote_policy).with(local_policy_path, remote_folder).and_return(remote_archive)
        expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
        expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
        expect(action).to receive(:upload_trusted_certs).with(remote_folder)
        expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
        expect(target_host).to receive(:run_command!)
          .with("#{subject.delete_folder} #{remote_folder}")
          .and_return(result)
        [:running_chef, :reboot].each do |n|
          expect(action).to receive(:notify).with(n)
        end
        subject.perform_action
      end
    end

    context "when command fails" do
      let(:result) { double("command result", exit_status: 1) }
      let(:report_result) { double("report result", exit_status: 0, stdout: '{ "exception": "thing" }') }
      let(:exception_mapper) { double("mapper") }
      before do
        expect(ChefRun::Errors::CCRFailureMapper).to receive(:new).
          and_return exception_mapper
      end

      it "reports back failure and reads the remote report" do
        expect(action).to receive(:create_remote_policy).with(local_policy_path, remote_folder).and_return(remote_archive)
        expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
        expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
        expect(action).to receive(:upload_trusted_certs).with(remote_folder)
        expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
        expect(target_host).to receive(:run_command!)
          .with("#{subject.delete_folder} #{remote_folder}")
        [:running_chef, :converge_error].each do |n|
          expect(action).to receive(:notify).with(n)
        end
        expect(target_host).to receive(:run_command).with(subject.read_chef_report).and_return(report_result)
        expect(target_host).to receive(:run_command!).with(subject.delete_chef_report)
        expect(exception_mapper).to receive(:raise_mapped_exception!)
        subject.perform_action
      end

      context "when remote report cannot be read" do
        let(:report_result) { double("report result", exit_status: 1, stdout: "", stderr: "") }
        it "reports back failure" do
          expect(action).to receive(:create_remote_policy).with(local_policy_path, remote_folder).and_return(remote_archive)
          expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
          expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
          expect(action).to receive(:upload_trusted_certs).with(remote_folder)
          expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
          expect(target_host).to receive(:run_command!)
            .with("#{subject.delete_folder} #{remote_folder}")
          [:running_chef, :converge_error].each do |n|
            expect(action).to receive(:notify).with(n)
          end
          expect(target_host).to receive(:run_command).with(subject.read_chef_report).and_return(report_result)
          expect(exception_mapper).to receive(:raise_mapped_exception!)
          subject.perform_action
        end
      end
    end
  end

end
