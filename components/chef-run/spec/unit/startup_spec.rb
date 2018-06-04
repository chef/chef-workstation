require "chef-run/startup"
require "chef-run/text"
require "chef-run/ui/terminal"

RSpec.describe ChefRun::Startup do
  let(:argv) { [] }
  let(:telemetry) { ChefRun::Telemeter.instance }
  subject do
    ChefRun::Startup.new(argv)
  end
  before do
    allow(ChefRun::UI::Terminal).to receive(:init)
  end

  after do
    ChefRun::Config.reset
  end

  describe "#initalize" do
    it "initializes the terminal" do
      expect_any_instance_of(ChefRun::Startup).to receive(:init_terminal)
      ChefRun::Startup.new([])
    end
  end

  describe "#run" do
    it "performs ordered startup tasks and invokes the CLI" do
      ordered_messages = [:first_run_tasks,
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
    context "when errors happen" do
      let(:error) { nil }
      let(:error_text) { ChefRun::Text.cli.error }
      before do
        # Force the error to happen in first_run_tasks, since it's always... well, first.
        expect(subject).to receive(:first_run_tasks).and_raise(error)
      end

      context "when an UnknownConfigOptionError is raised" do
        let(:bad_path) { "bad/path" }
        let(:bad_option) { "bad_option" }

        context "and it matches the expected text form" do
          let(:error) { Mixlib::Config::UnknownConfigOptionError.new("unsupported config value #{bad_option}.") }
          it "shows the correct error" do
            expected_text = error_text.invalid_config_key(bad_option, ChefRun::Config.location)
            expect(ChefRun::UI::Terminal).to receive(:output).with(expected_text)
            subject.run
          end
        end

        context "and it does not match the expeted text form" do
          let(:msg) { "something bad happened" }
          let(:error) { Mixlib::Config::UnknownConfigOptionError.new(msg) }
          it "shows the correct error" do
            expected_text = error_text.unknown_config_error(msg, ChefRun::Config.location)
            expect(ChefRun::UI::Terminal).to receive(:output).with(expected_text)
            subject.run
          end
        end
      end

      context "when a ConfigPathInvalid is raised" do
        let(:bad_path) { "bad/path" }
        let(:error) { ChefRun::Startup::ConfigPathInvalid.new(bad_path) }

        it "shows the correct error" do
          expected_text = error_text.bad_config_file(bad_path)
          expect(ChefRun::UI::Terminal).to receive(:output).with(expected_text)
          subject.run
        end
      end

      context "when a ConfigPathNotProvided is raised" do
        let(:error) { ChefRun::Startup::ConfigPathNotProvided.new }

        it "shows the correct error" do
          expected_text = error_text.missing_config_path
          expect(ChefRun::UI::Terminal).to receive(:output).with(expected_text)
          subject.run
        end
      end

      context "when a Tomlrb::ParserError is raised" do
        let(:msg) { "Parse failed." }
        let(:error) { Tomlrb::ParseError.new(msg) }

        it "shows the correct error" do
          expected_text = error_text.unknown_config_error(msg, ChefRun::Config.location)
          expect(ChefRun::UI::Terminal).to receive(:output).with(expected_text)
          subject.run
        end
      end
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

        context "and the path exists and is a valid file" do
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
    context "when a custom configuraton path is provided" do
      let(:config_path) { nil }
      it "loads the config at the custom path" do
        expect(subject).to receive(:custom_config_path).and_return config_path
        expect(ChefRun::Config).to receive(:custom_location).with config_path
        expect(ChefRun::Config).to receive(:load)
        subject.load_config
      end
      let(:config_path) { "/tmp/workstation-mock-config.toml" }
    end

    context "when no custom configuration path is provided" do
      let(:config_path) { nil }
      it "loads it at the default configuration path" do
        expect(subject).to receive(:custom_config_path).and_return config_path
        expect(ChefRun::Config).not_to receive(:custom_location)
        expect(ChefRun::Config).to receive(:load)
        subject.load_config
      end
    end

  end

  describe "#setup_logging" do
    let(:log_path) { "/tmp/logs" }
    let(:log_level) { :debug }
    before do
      ChefRun::Config.log.location = log_path
      ChefRun::Config.log.level = log_level
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
