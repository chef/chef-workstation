require "bundler/setup"
require "chef-workstation/text"
require "chef-workstation/log"
require "chef-workstation/ui/terminal"
RSpec.shared_context "Global helpers" do
  let(:t) { ChefWorkstation::Text }
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
    ChefWorkstation::Log.setup "/dev/null"
    ChefWorkstation::UI::Terminal.init(File.open("/dev/null", "w"))
  end
end
