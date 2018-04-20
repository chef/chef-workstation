
# Simple wrapper that runs the CLI and prevents it
# from aborting all tests with a SystemExit.
def run_cli_with(args)
  ChefWorkstation::CLI.new(args.split(" ")).run
rescue SystemExit
end

def fixture_content(name)
  content = File.read(File.join("spec/integration/fixtures", "#{name}.out"))
  content.gsub("$VERSION", ChefWorkstation::VERSION)
end
