#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require "benchmark"
require "forwardable"
require "singleton"
require "json"
require "digest/sha1"
require "securerandom"
require "chef-cli/version"
require "chef-cli/config"
require "yaml"

module ChefCLI

  # This definites the Telemetry interface. Implementation thoughts for
  # when we unstub it:
  # - let's track the call sequence; most of our calls will be nested inside
  # a main 'timed_capture', and it would be good to see ordering within nested calls.
  class Telemetry
    include Singleton
    class << self
      extend Forwardable
      def_delegators :instance, :timed_capture, :capture, :commit, :timed_action_capture, :timed_run_capture
      def_delegators :instance, :pending_event_count, :last_event
      def_delegators :instance, :make_event_payload
    end

    attr_reader :events_to_send, :run_timestamp

    def initialize
      @events_to_send = []
      @run_timestamp =  Time.now.utc.strftime("%FT%TZ")
    end

    def timed_action_capture(action, &block)
      # Note: we do not directly capture hostname for privacy concerns, but
      # using a sha1 digest will allow us to anonymously see
      # unique hosts to derive number of hosts affected by a command
      target = action.target_host
      target_data = { platform: {}, hostname_sha1: nil, transport_type: nil }
      if target
        target_data[:platform][:name] = target.base_os # :windows, :linux, eventually :macos
        target_data[:platform][:version] = target.version
        target_data[:platform][:architecture] = target.architecture
        target_data[:hostname_sha1] = Digest::SHA1.hexdigest(target.hostname.downcase)
        target_data[:transport_type] = target.transport_type
      end
      timed_capture(:action, { action: action.name, target: target_data }, &block)
    end

    def timed_run_capture(arguments, &block)
      timed_capture(:run, arguments: arguments, &block)
    end

    def capture(name, data = {})
      # Adding it to the head of the list will ensure that the
      # sequence of events is preserved when we send the final payload
      payload = make_event_payload(name, data)
      @events_to_send.unshift payload
    end

    def timed_capture(name, data = {})
      time = Benchmark.measure { yield }
      data[:duration] = time.real
      capture(name, data)
    end

    def commit
      session = convert_events_to_session
      write_session(session)
      @events_to_send = []
    end

    def make_event_payload(name, data)
      properties = {
        # We will submit this payload in a future run, so capture the time of actual execution:
        run_timestamp: run_timestamp,
        # This lets us filter out testing/dev actions, which may not
        # follow customer usage patterns:
        telemetry_mode:  ChefCLI::Config.telemetry.dev ? "dev" : "prod",
        host_platform: host_platform,
      }
      { event: name, properties: properties.merge(data) }
    end

    # For testing.
    def pending_event_count
      @events_to_send.length
    end

    def last_event
      @events_to_send.last
    end

    private

    def host_platform
      @host_platform ||= case RUBY_PLATFORM
                         when /mswin|mingw|windows/
                           "windows"
                         else
                           RUBY_PLATFORM.split("-")[1]
                         end
    end

    def convert_events_to_session
      YAML.dump({ "entries" => @events_to_send })
    end

    def write_session(session)
      File.write(next_filename, convert_events_to_session)
    end

    def next_filename
      id = 0
      filename = ""
      loop do
        id += 1
        filename = File.join(ChefCLI::Config.telemetry_path,
                             "telemetry-payload-#{id}.yml")
        break unless File.exist?(filename)
      end
      filename
    end

  end
end
