

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

    context "for a subcommand" do
      ["-h", "--help", "help"].each do |flag|

        it "shows subcommand help when help command prefixed" do
          expect { run_cli_with("#{flag} target") }.to output(/^#{t.commands.target.description}/).to_stdout
        end
        it "shows subcommand help when help command postfixed" do
          expect { run_cli_with("target #{flag}") }.to output(/^#{t.commands.target.description}/).to_stdout
        end
      end
    end

    context "for a nested subcommand" do
      ["-h", "--help", "help"].each do |flag|
        it "shows nested subcommand help when help command prefixed" do
          expect { run_cli_with("#{flag} target converge") }.to output(/^#{t.commands.target.converge.description}/).to_stdout
        end
        it "shows nested subcommand help when help command postfixed" do
          expect { run_cli_with("target converge #{flag}") }.to output(/^#{t.commands.target.converge.description}/).to_stdout
        end
        it "shows help of subcommand preceding the flag when help command sandwiched" do
          expect { run_cli_with("target #{flag} converge") }.to output(/^#{t.commands.target.description}/).to_stdout
        end
      end
    end
    context "for an alias" do
      ["-h", "--help", "help"].each do |flag|
        it "shows help as if for the underlying command when help command postfixed" do
          expect { run_cli_with("converge #{flag}") }.to output(/^#{t.commands.target.converge.description}/).to_stdout
        end
        it "shows help as if for the underlying command when help command prefixed" do
          expect { run_cli_with("converge #{flag}") }.to output(/^#{t.commands.target.converge.description}/).to_stdout
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

  context "when an invalid command is provided" do
    it "shows the correct error" do
      expect { run_cli_with("blah") }.to output(fixture_content("chef_invalid_command")).to_stdout
    end
  end

end
