

require "spec_helper"
require "integration/spec_helper"
require "chef-workstation/cli"
require "chef-workstation/version"

RSpec.describe ChefWorkstation::CLI do
  let(:args) { [] }
  # We could shell out, but this will run a little faster as we
  # accumulate more - and will work better to get accurate coverage reporting.
  let(:command) { ChefWorkstation::CLI.new(args) }
  context "top-level chef command" do
    context "help output" do
      ["-h", "--help", "help", ""].each do |arg|
        it "#{arg} displays correct help" do
          expect { run_cli_with(arg) }.to output(fixture_content("chef_help")).to_stdout
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
end
