require "spec_helper"
require "chef-workstation/ui/error_printer"
require "chef-workstation/remote_connection"

RSpec.describe ChefWorkstation::UI::ErrorPrinter do
  let(:orig_exception) { StandardError.new("test") }
  let(:conn) { ChefWorkstation::RemoteConnection.make_connection("mock://localhost") }
  let(:wrapped_exception) { ChefWorkstation::WrappedError.new(orig_exception, conn) }
  subject(:printer) { ChefWorkstation::UI::ErrorPrinter.new(wrapped_exception, nil) }

  context "#format_error" do
    it "formats the message" do
      expect(subject).to receive(:format_header).and_return "header"
      expect(subject).to receive(:format_body).and_return "body"
      expect(subject).to receive(:format_footer).and_return "footer"
      expect(subject.format_error).to eq "\nheader\n\nbody\nfooter\n"
    end
  end

  context "#format_body" do
    RC = ChefWorkstation::RemoteConnection
    context "when exception is a ChefWorkstation::Error" do
      let(:result) { RemoteExecResult.new(1, "", "failed") }
      let(:orig_exception) { RC::RemoteExecutionFailed.new("localhost", "test", result) }
      it "invokes the right handler" do
        expect(subject).to receive(:format_workstation_exception)
        subject.format_body
      end
    end

    context "when exception is a Train::Error" do
      # These may expand as we find error-specific messaging we can provide to customers
      # for more specific train exceptions
      let(:orig_exception) { Train::Error.new("test") }
      it "invokes the right handler" do
        expect(subject).to receive(:format_train_exception)
        subject.format_body
      end
    end

    context "when exception is something else" do
      # These may expand as we find error-specific messaging we can provide to customers
      # for more specific general exceptions
      it "invokes the right handler" do
        expect(subject).to receive(:format_other_exception)
        subject.format_body
      end
    end
  end

  context "#format_footer" do

    let(:show_log) { true }
    let(:show_stack) { true }
    let(:formatter) do
      ChefWorkstation::UI::ErrorPrinter.new(wrapped_exception, nil)
    end

    subject(:format_footer) do
      lambda { formatter.format_footer }
    end

    before do
      allow(formatter).to receive(:show_log).and_return show_log
      allow(formatter).to receive(:show_stack).and_return show_stack
    end

    context "when both log and stack wanted" do
      let(:show_log) { true }
      let(:show_stack) { true }
      assert_string_lookup("errors.footer.both")
    end

    context "when only log is wanted" do
      let(:show_log) { true }
      let(:show_stack) { false }
      assert_string_lookup("errors.footer.log_only")
    end

    context "when only stack is wanted" do
      let(:show_log) { false }
      let(:show_stack) { true }
      assert_string_lookup("errors.footer.stack_only")
    end

    context "when neither log nor stack wanted" do
      let(:show_log) { false }
      let(:show_stack) { false }
      assert_string_lookup("errors.footer.neither")
    end
  end

  context ".write_backtrace" do
    let(:inst) { double(ChefWorkstation::UI::ErrorPrinter) }
    before do
      allow(ChefWorkstation::UI::ErrorPrinter).to receive(:new).and_return inst
    end

    let(:orig_args) { %w{test} }
    it "formats and saves the backtrace" do
      expect(inst).to receive(:add_backtrace_header).with(anything(), orig_args)
      expect(inst).to receive(:add_formatted_backtrace)
      expect(inst).to receive(:save_backtrace)
      ChefWorkstation::UI::ErrorPrinter.write_backtrace(wrapped_exception, orig_args)
    end
  end
end
