require "chef-workstation/log"
require "spec_helper"

RSpec.describe ChefWorkstation::Log do
  Log = ChefWorkstation::Log
  let(:output) { StringIO.new }

  before do
    Log.setup output, :debug
  end

  after do
    Log.setup "/dev/null", :error
  end

  it "correctly logs to stdout" do
    Log.debug("test")
    expect(output.string).to match(/DEBUG: test$/)
  end
end
