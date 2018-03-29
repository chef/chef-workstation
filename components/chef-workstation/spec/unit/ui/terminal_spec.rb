require "chef-workstation/ui/terminal"
require "spec_helper"

RSpec.describe ChefWorkstation::UI::Terminal do
  Terminal = ChefWorkstation::UI::Terminal
  let(:capture) { StringIO.new }

  # We must set the terminal location to $stdout because
  # of how RSpec works - trying to set it in a before block
  # won't capture the output
  # https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/output-matcher

  after do
    Terminal.init(File.open("/dev/null", "w"))
  end

  it "correctly outputs a message" do
    expect do
      Terminal.output("test")
    end.to output("test\n").to_terminal
  end

  # The spinner REALLY doesn't want to send output to anything besides a real
  # stdout. Maybe it has something to do with a tty check?
  it "correctly passes a block to the spinner and executes it" do
    @ran = false
    Terminal.spinner("a message") { |reporter| @ran = true }
    expect(@ran).to eq true
  end
end
