require "spec_helper"
require "chef-workstation/action/converge_target"
require "chef-workstation/target_host"
require "chef-workstation/errors/ccr_failure_mapper"
require "chef-workstation/temp_cookbook"

RSpec.describe ChefWorkstation::Action::ConvergeTarget do
  let(:archive) { "archive.tgz" }
  let(:target_host) do
    p = double("platform", family: "windows")
    instance_double(ChefWorkstation::TargetHost, platform: p)
  end
  let(:local_cookbook) { instance_double(ChefWorkstation::TempCookbook, path: "/local") }
  let(:opts) { { target_host: target_host, local_cookbook: local_cookbook } }
  subject(:action) { ChefWorkstation::Action::ConvergeTarget.new(opts) }

  describe "#create_remote_policy" do
    let(:policyfile_install) { instance_double(ChefDK::PolicyfileServices::Install, run: nil) }
    let(:export_repo) { instance_double(ChefDK::PolicyfileServices::ExportRepo, run: nil, archive_file_location: archive) }
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_archive) { File.join(remote_folder, File.basename(archive)) }

    before do
      expect(ChefDK::PolicyfileServices::Install).to receive(:new).with(
        ui: an_instance_of(ChefDK::UI),
        root_dir: local_cookbook.path
      ).and_return(policyfile_install)
      expect(ChefDK::PolicyfileServices::ExportRepo).to receive(:new).with(
        policyfile: File.join(local_cookbook.path, "Policyfile.lock.json"),
        root_dir: local_cookbook.path,
        export_dir: File.join(local_cookbook.path, "export"),
        archive: true,
        force: true
      ).and_return(export_repo)
    end

    it "pushes it to the remote machine" do
      expect(target_host).to receive(:upload_file).with(archive, remote_archive)
      expect(action.create_remote_policy(local_cookbook, remote_folder)).to eq(remote_archive)
    end

    it "raises an error if the upload fails" do
      expect(target_host).to receive(:upload_file).with(archive, remote_archive).and_raise("foo")
      err = ChefWorkstation::Action::ConvergeTarget::PolicyUploadFailed
      expect { action.create_remote_policy(local_cookbook, remote_folder) }.to raise_error(err)
    end
  end

  describe "#create_remote_config" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_config) { "#{remote_folder}/workstation.rb" }
    let!(:local_tempfile) { Tempfile.new }

    it "pushes it to the remote machine" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config)
      expect(action.create_remote_config(remote_folder)).to eq(remote_config)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end

    it "raises an error if the upload fails" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_config).and_raise("foo")
      err = ChefWorkstation::Action::ConvergeTarget::ConfigUploadFailed
      expect { action.create_remote_config(remote_folder) }.to raise_error(err)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end
  end

  describe "#create_remote_handler" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_reporter) { "#{remote_folder}/reporter.rb" }
    let!(:local_tempfile) { Tempfile.new }

    it "pushes it to the remote machine" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_reporter)
      expect(action.create_remote_handler(remote_folder)).to eq(remote_reporter)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end

    it "raises an error if the upload fails" do
      expect(Tempfile).to receive(:new).and_return(local_tempfile)
      expect(target_host).to receive(:upload_file).with(local_tempfile.path, remote_reporter).and_raise("foo")
      err = ChefWorkstation::Action::ConvergeTarget::HandlerUploadFailed
      expect { action.create_remote_handler(remote_folder) }.to raise_error(err)
      # ensure the tempfile is deleted locally
      expect(local_tempfile.closed?).to eq(true)
    end
  end

  describe "#perform_action" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_archive) { File.join(remote_folder, File.basename(archive)) }
    let(:remote_config) { "#{remote_folder}/workstation.rb" }
    let(:remote_handler) { "#{remote_folder}/reporter.rb" }
    let(:tmpdir) { double("tmpdir", exit_status: 0, stdout: remote_folder) }
    before do
      expect(target_host).to receive(:run_command!).with(action.mktemp).and_return(tmpdir)
    end
    let(:result) { double("command result", exit_status: 0, stdout: "") }

    it "runs the converge and reports back success" do
      expect(action).to receive(:create_remote_policy).with(local_cookbook, remote_folder).and_return(remote_archive)
      expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
      expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
      expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
      expect(target_host).to receive(:run_command!)
        .with("#{action.delete_folder} #{remote_folder}")
        .and_return(result)
      [:creating_remote_policy, :running_chef, :success].each do |n|
        expect(action).to receive(:notify).with(n)
      end
      action.perform_action
    end

    context "when command fails" do
      let(:result) { double("command result", exit_status: 1) }
      let(:report_result) { double("report result", exit_status: 0, stdout: '{ "exception": "thing" }') }
      let(:exception_mapper) { double("mapper") }
      before do
        expect(ChefWorkstation::Errors::CCRFailureMapper).to receive(:new).
          and_return exception_mapper
      end

      it "reports back failure and reads the remote report" do
        expect(action).to receive(:create_remote_policy).with(local_cookbook, remote_folder).and_return(remote_archive)
        expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
        expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
        expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
        expect(target_host).to receive(:run_command!)
          .with("#{action.delete_folder} #{remote_folder}")
        [:creating_remote_policy, :running_chef, :error].each do |n|
          expect(action).to receive(:notify).with(n)
        end
        expect(target_host).to receive(:run_command).with(action.read_chef_report).and_return(report_result)
        expect(target_host).to receive(:run_command!).with(action.delete_chef_report)
        expect(exception_mapper).to receive(:raise_mapped_exception!)
        action.perform_action
      end

      context "when remote report cannot be read" do
        let(:report_result) { double("report result", exit_status: 1, stdout: "", stderr: "") }
        it "reports back failure" do
          expect(action).to receive(:create_remote_policy).with(local_cookbook, remote_folder).and_return(remote_archive)
          expect(action).to receive(:create_remote_config).with(remote_folder).and_return(remote_config)
          expect(action).to receive(:create_remote_handler).with(remote_folder).and_return(remote_handler)
          expect(target_host).to receive(:run_command).with(/chef-client.+#{archive}/).and_return(result)
          expect(target_host).to receive(:run_command!)
            .with("#{action.delete_folder} #{remote_folder}")
          [:creating_remote_policy, :running_chef, :error].each do |n|
            expect(action).to receive(:notify).with(n)
          end
          expect(target_host).to receive(:run_command).with(action.read_chef_report).and_return(report_result)
          expect(exception_mapper).to receive(:raise_mapped_exception!)
          action.perform_action
        end
      end
    end
  end

end
