

require "spec_helper"
require "integration/spec_helper"
require "chef-workstation/cli"
require "chef-workstation/version"

RSpec.describe "chef" do
  context "help output" do
    context "at the top level" do
      ["-h", "--help", "help", ""].each do |arg|
        it "#{arg} displays correct help" do
          expect { run_cli_with(arg) }.to output(fixture_content("chef_help")).to_stdout
        end
      end
    end
  end
  context "version output" do
    ["-v", "--version", "version"].each do |arg|
      it "#{arg} displays correct version" do
        expect { run_cli_with(arg) }.to output(fixture_content("chef_version")).to_stdout
      end
    end
  end
end
