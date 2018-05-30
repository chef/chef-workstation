require "chef-run/startup"

RSpec.describe ChefRun::Startup do
  let(:argv) { [] }
  let(:telemetry) { ChefRun::Telemeter.instance }
  subject do
    ChefRun::Startup.new(argv)
  end

  describe "#run" do
    it "performs ordered startup tasks and invokes the CLI" do
      ordered_messages = [:init_terminal,
                          :first_run_tasks,
                          :setup_workstation_user_directories,
                          :load_config,
                          :setup_logging,
                          :start_telemeter_upload,
                          :start_chef_run]
      ordered_messages.each do |msg|
        expect(subject).to receive(msg).ordered
      end

      subject.run()
    end
  end
  describe "#init_terminal" do
    it "initializees the terminal for stdout" do
      expect(ChefRun::UI::Terminal).to receive(:init).with($stdout)
      subject.init_terminal
    end
  end
  describe "#first_run_tasks" do
    let(:first_run_complete) { true }
    before do
      allow(Dir).to receive(:exist?).with(ChefRun::Config::WS_BASE_PATH).and_return first_run_complete
    end

    context "when first run has already occurred" do
      let(:first_run_complete) { true }
      it "returns without taking action" do
        expect(subject).to_not receive(:create_default_config)
        expect(subject).to_not receive(:setup_telemetry)
        subject.first_run_tasks
      end
    end
    context "when first run has not already occurred" do
      let(:first_run_complete) { false }
      it "Performs required first-run tasks" do
        expect(subject).to receive(:create_default_config)
        expect(subject).to receive(:setup_telemetry)
        subject.first_run_tasks
      end
    end
  end

  describe "#create_default_config" do
    it "touches the configuration file to create it and notifies that it has done so" do
      expected_config_path = ChefRun::Config.default_location
      expected_message = ChefRun::Text.cli.creating_config(expected_config_path)
      expect(ChefRun::UI::Terminal).to receive(:output).
        with(expected_message)
      expect(ChefRun::UI::Terminal).to receive(:output).
        with("")
      expect(FileUtils).to receive(:touch).
        with(expected_config_path)
      subject.create_default_config

    end
  end

  describe "#setup_telemetry" do
    let(:mock_guid) { "1234" }
    it "sets up a telemetry installation id and notifies the operator that telemetry is enabled" do
      expect(SecureRandom).to receive(:uuid).and_return(mock_guid)
      expect(File).to receive(:write).
        with(ChefRun::Config.telemetry_installation_identifier_file, mock_guid)
      subject.setup_telemetry
    end
  end

  describe "#start_telemeter_upload" do
    it "launches telemetry uploads" do
      expect(ChefRun::Telemeter::Sender).to receive(:start_upload_thread)
      subject.start_telemeter_upload
    end
  end

  describe "setup_workstation_user_directories" do
    it "creates the required chef-workstation directories in HOME" do
      expect(FileUtils).to receive(:mkdir_p).with(ChefRun::Config::WS_BASE_PATH)
      expect(FileUtils).to receive(:mkdir_p).with(ChefRun::Config.base_log_directory)
      expect(FileUtils).to receive(:mkdir_p).with(ChefRun::Config.telemetry_path)
      subject.setup_workstation_user_directories
    end
  end

  describe "#custom_config_path" do
    context "when a custom config path is not provided as an option" do
      let(:args) { [] }
      it "returns nil" do
        expect(subject.custom_config_path).to be_nil
      end
    end

    context "when a --config-path is provided" do
      context "but the actual path parameter is not provided" do
        let(:argv) { %w{--config-path} }
        it "raises ConfigPathNotProvided" do
          expect { subject.custom_config_path }.to raise_error(ChefRun::Startup::ConfigPathNotProvided)
        end
      end

      context "and the path is provided" do
        let(:path) { "/mock/file.toml" }
        let(:argv) { ["--config-path", path] }

        context "but the path is not a file" do
          before do
            allow(File).to receive(:file?).with(path).and_return false
          end
          it "raises an error ConfigPathInvalid" do
            expect { subject.custom_config_path }.to raise_error(ChefRun::Startup::ConfigPathInvalid)
          end
        end

        context "and the path exists and is a fvalid" do
          before do
            allow(File).to receive(:file?).with(path).and_return true
          end

          context "but it is not readable" do
            before do
              allow(File).to receive(:readable?).with(path).and_return false
            end
            it "raises an error ConfigPathInvalid" do
              expect { subject.custom_config_path }.to raise_error(ChefRun::Startup::ConfigPathInvalid)
            end

          end

          context "and it is readable" do
            before do
              allow(File).to receive(:readable?).with(path).and_return true
            end
            it "returns the custom path" do
              expect(subject.custom_config_path).to eq path
            end
          end
        end
      end
    end
  end

  describe "#load_config" do
    it "finds the config path, initializes it, and loads config" do
      mock_path = "/tmp/path.file"
      expect(subject).to receive(:custom_config_path).and_return mock_path
      expect(ChefRun::Config).to receive(:custom_location).with mock_path
      expect(ChefRun::Config).to receive(:load)
      subject.load_config
    end
  end

  describe "#setup_logging" do
    let(:log_path) { "/tmp/logs" }
    let(:log_level) { :debug }
    before do
      ChefRun::Config.log.location = log_path
      ChefRun::Config.log.level = log_level
    end

    after do
      ChefRun::Config.reset
    end

    it "sets up the logger with the correct log path" do
      expect(ChefRun::Log).to receive(:setup).
        with(log_path, log_level)
      subject.setup_logging
    end
  end

  describe "#start_chef_run" do
    let(:argv) { %w{some arguments} }
    it "runs ChefRun::CLI and passes along arguments it received" do
      run_double = instance_double(ChefRun::CLI)
      expect(ChefRun::CLI).to receive(:new).with(argv).and_return(run_double)
      expect(run_double).to receive(:run)
      subject.start_chef_run
    end
  end
end
