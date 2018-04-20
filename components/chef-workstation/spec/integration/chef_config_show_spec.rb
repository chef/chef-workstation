require "spec_helper"
require "integration/spec_helper"

RSpec.describe "chef config" do
  context "help output" do
    it "shows help for chef config when asked" do
      expect { run_cli_with("config show -h") }.to output(fixture_content("chef_config_show_help")).to_stdout
    end
  end

end

