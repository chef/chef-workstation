
require "chef-cli/cli"
require "chef-cli/version"

# Create the chef configuration directory and touch the config
# file.
# this makes sure our output doesn't include
# an extra line telling us that it's created,
# causing the first integration test to execute to fail on
# CI.
# TODO this is not ideal... let's look at
# testing the output correctly in both cases,
# possible forcing a specific test that will also create
# the directory to run first.
dir = File.join(Dir.home, ".chef-workstation")
conf = File.join(dir, "config.toml")
FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
FileUtils.touch(conf) unless File.exist?(conf)

# Simple wrapper that runs the CLI and prevents it
# from aborting all tests with a SystemExit.
# We could shell out, but this will run a little faster as we
# accumulate more things to test - and will work better to get
# accurate simplecov coverage reporting.
# usage:
#   expect {run_with_cli("blah")}.to output("blah").to_stdout
def run_cli_with(args)
  ChefCLI::CLI.new(args.split(" ")).run
rescue SystemExit
end

def fixture_content(name)
  content = File.read(File.join("spec/integration/fixtures", "#{name}.out"))
  # Replace $VERSION if present - this is updated automatically, so we can't include
  #                               the literal version value in the fixture without
  #                               having expeditor update it there too...
  content.gsub("$VERSION", ChefCLI::VERSION).
    gsub("$HOME", Dir.home)
end
