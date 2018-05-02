require "bundler/setup"
require "simplecov"
require "chef-workstation/text"
require "chef-workstation/log"
require "chef-workstation/ui/terminal"
require "rspec/expectations"
require "support/matchers/output_to_terminal"
require "r18n-desktop"

RSpec.shared_context "Global helpers" do
  let(:t) { ChefWorkstation::Text }
end

RemoteExecResult = Struct.new(:exit_status, :stdout, :stderr)

class ChefWorkstation::MockReporter
  def update(msg); ChefWorkstation::UI::Terminal.output msg; end

  def success(msg); ChefWorkstation::UI::Terminal.output "SUCCESS: #{msg}"; end

  def error(msg); ChefWorkstation::UI::Terminal.output "FAILURE: #{msg}"; end
end

# TODO would read better to make this a custom matcher.
# Simulates a recursive string lookup on the Text object
#
# assert_string_lookup("tree.tree.tree.leaf", "a returned string")
# TODO this can be more cleanly expressed as a custom matcher...
def assert_string_lookup(key, retval = "testvalue")
  it "should look up string #{key}" do
    top_level_method, *call_seq = key.split(".")
    terminal_method = call_seq.pop
    tmock = double()
    # Because ordering is important
    # (eg calling errors.hello is different from hello.errors),
    # we need to add this individually instead of using
    # `receive_messages`, which doesn't appear to give a way to
    # guarantee ordering
    expect(ChefWorkstation::Text).to receive(top_level_method).
      and_return(tmock)
    call_seq.each do |m|
      expect(tmock).to receive(m).ordered.and_return(tmock)
    end
    expect(tmock).to receive(terminal_method).
      ordered.and_return(retval)
    subject.call
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include_context "Global helpers"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:all) do
    ChefWorkstation::Log.setup "/dev/null", :error
    ChefWorkstation::UI::Terminal.init(File.open("/dev/null", "w"))
  end
end

if ENV["CIRCLE_ARTIFACTS"]
  dir = File.join(ENV["CIRCLE_ARTIFACTS"], "coverage")
  SimpleCov.coverage_dir(dir)
end
SimpleCov.start
