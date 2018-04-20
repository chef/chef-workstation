require "spec_helper"
require "integration/spec_helper"

RSpec.describe "chef config" do
  context "default output" do
    it "shows help for chef config" do
      expect { run_cli_with("config") }.to output(fixture_content("chef_config_help")).to_stdout
    end
  end
end
