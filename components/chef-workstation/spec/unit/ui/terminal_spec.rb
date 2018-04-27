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

  context "#render_action" do
    it "executes the provided action" do
      @ran = false
      Terminal.render_action("a message") { |reporter| @ran = true }
      expect(@ran).to eq true
    end
  end

  context "#render_parallel_actions" do
    it "executes the provided actions" do
      @action1ran = false
      @action2ran = false
      action1 = Terminal::Action.new("prefix") do
        @action1ran = true
      end
      action2 = Terminal::Action.new("prefix") do
        @action2ran = true
      end
      Terminal.render_parallel_actions("a message", [action1, action2])
      expect(@action1ran).to eq true
      expect(@action2ran).to eq true
    end
  end

  # The spinner REALLY doesn't want to send output to anything besides a real
  # stdout. Maybe it has something to do with a tty check?
  it "correctly passes a block to the spinner and executes it" do
  end
end
