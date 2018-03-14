require "chef-workstation/ui/command_outputer"
require "spec_helper"

RSpec.describe ChefWorkstation::UI::CommandOutputer do
  Outputer = ChefWorkstation::UI::CommandOutputer
  let(:capture) { StringIO.new }

  # We must set the outputer location to $stdout because
  # of how RSpec works - trying to set it in a before block
  # won't capture the output
  # https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/output-matcher

  after do
    Outputer.init(File.open("/dev/null", "w"))
  end

  it "correctly outputs a message" do
    expect do
      Outputer.init($stdout)
      Outputer.output("test")
    end.to output("test\n").to_stdout
  end

  # The spinner REALLY doesn't want to send output to anything besides a real
  # stdout. Maybe it has something to do with a tty check?
  it "correctly passes a block to the spinner and executes it", :pending do
    expect do
      Outputer.init($stdout)
      Outputer.spinner("a message") { |reporter| sleep 1 }
    end.to output("test\n").to_stdout
  end
end
