require "telemetry"
require "chef-cli/telemetry/patch"
require "chef-cli/log"
require "chef-cli/version"

module ChefCLI
  class Telemetry
    class Sender
      def run
        session_files.each { |path| process_session(path) }
        ChefCLI::Log.info("Terminating, nothing more to do.")
      end

      def session_files
        ChefCLI::Log.info("Looking for telemetry data to submit")
        session_search = File.join(ChefCLI::Config.telemetry_path, "telemetry-payload-*.yml")
        files = Dir.glob(session_search)
        ChefCLI::Log.info("Found #{files.length} sessions to submit")
        files
      end

      def process_session(path)
        ChefCLI::Log.info("Processing telemetry entries from #{path}")
        content = load_and_clear_session(path)
        submit_session(content)
      end

      def submit_session(content)
        # Each file contains the actions taken within a single run of the chef tool.
        # Each run is one session, so we'll first remove remove the session file
        # to force creating a new one.
        FileUtils.rm_rf(ChefCLI::Config.telemetry_session_file)
        telemetry = ::Telemetry.new(product: "chef-workstation-cli",
                                    origin: "command-line",
                                    product_version: ChefCLI::VERSION,
                                    install_context: "omnibus")
        entries = content["entries"]
        total = entries.length
        entries.each_with_index do |entry, x|
          submit_entry(telemetry, entry, x + 1, total)
        end
      end

      def submit_entry(telemetry, entry, sequence, total)
        ChefCLI::Log.info("Submitting telemetry entry #{sequence}/#{total}: #{entry} ")
        telemetry.deliver(entry)
        ChefCLI::Log.info("Entry #{sequence}/#{total} submitted.")
      rescue => e
        # No error handling in telemetry lib, so at least track the failrue
        ChefCLI::Log.error("Failed to send entry #{sequence}/#{total}: #{e}")
        ChefCLI::Log.error("Backtrace: #{e.backtrace} ")
      end

      private

      def load_and_clear_session(path)
        content = File.read(path)
        # We'll remove it now instead of after we parse or submit it -
        # if we fail to deliver, we don't want to be stuck resubmitting it if the problem
        # was due to payload. This is a trade-off - if we get a transient error, the
        # payload will be lost.
        # TODO: Improve error handling so we can intelligently decide whether to
        #       retry a failed load or failed submit.
        FileUtils.rm_rf(path)
        YAML.load(content)
      end
    end
  end
end
