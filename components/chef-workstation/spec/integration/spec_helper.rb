
require "chef-workstation/cli"
require "chef-workstation/version"

# Simple wrapper that runs the CLI and prevents it
# from aborting all tests with a SystemExit.
# We could shell out, but this will run a little faster as we
# accumulate more things to test - and will work better to get
# accurate simplecov coverage reporting.
# usage:
#   expect {run_with_cli("blah")}.to output("blah").to_stdout
def run_cli_with(args)
  ChefWorkstation::CLI.new(args.split(" ")).run
rescue SystemExit
end

def fixture_content(name)
  content = File.read(File.join("spec/integration/fixtures", "#{name}.out"))
  # Replace $VERSION if present - this is updated automatically, so we can't include
  #                               the literal version value in the fixture without
  #                               having expeditor update it there too...
  content.gsub("$VERSION", ChefWorkstation::VERSION).
    gsub("$HOME", Dir.home)
end
