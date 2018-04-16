require "spec_helper"
require "chef-workstation/action/converge_target"
require "chef-workstation/remote_connection"
require "chef-workstation/errors/ccr_failure_mapper"

RSpec.describe ChefWorkstation::Action::ConvergeTarget do
  let(:connection) do
    p = double("platform", family: "windows")
    instance_double(ChefWorkstation::RemoteConnection, platform: p)
  end
  let(:r1) { "directory" }
  let(:r2) { "/tmp" }
  let(:props) { nil }
  let(:opts) { { connection: connection, resource_type: r1, resource_name: r2, properties: props } }
  subject(:action) { ChefWorkstation::Action::ConvergeTarget.new(opts) }

  describe "#create_resource" do
    context "when no properties are provided" do
      it "it creates a simple resource" do
        expect(action.create_resource(r1, r2, [])).to eq("directory '/tmp'\n")
      end
    end

    context "when properties are provided" do
      let(:props) do
        {
          "key1" => "value",
          "key2" => 0.1,
          "key3" => 100,
          "key4" => true,
          "key_with_underscore" => "value",
        }
      end

      it "convertes the properties to chef-client args" do
        expected = <<-EOH.gsub(/^\s{10}/, "")
          directory '/tmp' do
            key1 'value'
            key2 0.1
            key3 100
            key4 true
            key_with_underscore 'value'
          end
          EOH
        expect(action.create_resource(r1, r2, props)).to eq(expected)
      end
    end
  end

  describe "#create_remote_recipe" do
    let(:remote_folder) { "/tmp/foo" }
    let(:remote_recipe) { "#{remote_folder}/recipe.rb" }
    let(:tmpdir) { double("tmpdir", exit_status: 0, stdout: remote_folder) }
    before do
      expect(connection).to receive(:run_command!).with(action.mktemp).and_return(tmpdir)
    end

    context "when using a local recipe" do
      let(:local_recipe) { "/local" }
      let(:config) { { recipe_path: local_recipe } }

      it "pushes it to the remote machine" do
        expect(connection).to receive(:upload_file).with(local_recipe, remote_recipe)
        expect(action.create_remote_recipe(config)).to eq(remote_recipe)
      end

      it "raises an error if the upload fails" do
        expect(connection).to receive(:upload_file).with(local_recipe, remote_recipe).and_raise("foo")
        err = ChefWorkstation::Action::ConvergeTarget::RecipeUploadFailed
        expect { action.create_remote_recipe(config) }.to raise_error(err)
      end
    end

    context "when using a resource" do
      let(:config) { { resource_type: r1, resource_name: r2 } }
      let!(:local_tempfile) { Tempfile.new }

      it "pushes it to the remote machine" do
        expect(Tempfile).to receive(:new).and_return(local_tempfile)
        expect(connection).to receive(:upload_file).with(local_tempfile.path, remote_recipe)
        expect(action.create_remote_recipe(config)).to eq(remote_recipe)
        # ensure the tempfile is deleted locally
        expect(local_tempfile.closed?).to eq(true)
      end

      it "raises an error if the upload fails" do
        expect(Tempfile).to receive(:new).and_return(local_tempfile)
        expect(connection).to receive(:upload_file).with(local_tempfile.path, remote_recipe).and_raise("foo")
        err = ChefWorkstation::Action::ConvergeTarget::ResourceUploadFailed
        expect { action.create_remote_recipe(config) }.to raise_error(err)
        # ensure the tempfile is deleted locally
        expect(local_tempfile.closed?).to eq(true)
      end
    end
  end

  describe "#perform_action" do
    let(:config) { { resource_type: r1, resource_name: r2, properties: props } }
    let(:remote_recipe) { "/tmp/recipe.rb" }
    let(:result) { double("command result", exit_status: 0, stdout: "") }

    it "runs the converge and reports back success" do
      expect(action).to receive(:create_remote_recipe).with(config).and_return(remote_recipe)
      expect(connection).to receive(:run_command).with(/chef-client.+#{remote_recipe}/).and_return(result)
      expect(connection).to receive(:run_command!)
        .with("#{action.delete_folder} #{File.dirname(remote_recipe)}")
        .and_return(result)
      expect(action).to receive(:notify).with(:success)
      action.perform_action
    end

    context "when command fails" do
      let(:result) { double("command result", exit_status: 1) }
      let(:stacktrace_result) { double("stacktrace scrape result", exit_status: 0, stdout: "") }
      let(:exception_mapper) { double("mapper") }
      before do
        expect(ChefWorkstation::Errors::CCRFailureMapper).to receive(:new).
          and_return exception_mapper
      end

      it "reports back failure and scrapes the remote log" do
        expect(action).to receive(:create_remote_recipe).with(config).and_return(remote_recipe)
        expect(connection).to receive(:run_command).with("#{action.chef_client} #{remote_recipe} --local-mode --no-color").and_return(result)
        expect(connection).to receive(:run_command!)
          .with("#{action.delete_folder} #{File.dirname(remote_recipe)}")
        expect(action).to receive(:notify).with(:error)
        expect(connection).to receive(:run_command).with(action.read_chef_stacktrace).and_return(stacktrace_result)
        expect(connection).to receive(:run_command!).with(action.delete_chef_stacktrace)
        expect(exception_mapper).to receive(:raise_mapped_exception!)
        action.perform_action
      end

      context "when remote log cannot be scraped" do
        let(:stacktrace_result) { double("stacktrace scrape result", exit_status: 1, stdout: "", stderr: "") }
        it "reports back failure" do
          expect(action).to receive(:create_remote_recipe).with(config).and_return(remote_recipe)
          expect(connection).to receive(:run_command).with("#{action.chef_client} #{remote_recipe} --local-mode --no-color").and_return(result)
          expect(connection).to receive(:run_command!)
            .with("#{action.delete_folder} #{File.dirname(remote_recipe)}")
          expect(action).to receive(:notify).with(:error)
          expect(connection).to receive(:run_command).with(action.read_chef_stacktrace).and_return(stacktrace_result)
          expect(exception_mapper).to receive(:raise_mapped_exception!)
          action.perform_action
        end
      end
    end
  end

end
