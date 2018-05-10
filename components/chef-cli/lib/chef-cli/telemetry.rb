#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
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
require "singleton"
require "forwardable"
require "benchmark"
require "chef-cli/version"
require "chef-cli/config"

module ChefCLI
  # This definites the Telemetry interface. Implementation thoughts for
  # when we unstub it:
  # - let's track the call sequence; most of our calls will be nested inside
  # a main 'timed_capture', and it would be good to see ordering within nested calls.
  class Telemetry
    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :timed_capture, :capture, :send!
      def_delegators :instance, :pending_event_count, :last_event
      def_delegators :instance, :make_event_payload
    end

    def initialize
      @events_to_send = []
    end

    def capture(name, data = {})
      # Adding it to the head of the list will ensure that the
      # sequence of events is preserved when we send the final payload
      @events_to_send.unshift make_event_payload(name, data)
    end

    def timed_capture(name, data = {})
      time = Benchmark.measure { yield }
      data[:duration] = time.real
      capture(name, data)
    end

    def send!
      # TODO implement
      @events_to_send = []
    end

    # TODO - should be private, but testing - move to be public in an Impl class?
    def make_event_payload(name, data)
      payload = { event: name, data: data, properties:
                  { time: Time.new.utc } }
      if name == :run
        # Don't recapture all of the 'property' data with every call - only
        # the top-level 'usage' call for this session.
        # TODO: Whether this omission makes sense will depend on
        #       the telemetry impl.
        additional = {
          usage_type:  ChefCLI::Config.telemetry.dev ? "dev" : "prod",
          version: ChefCLI::VERSION,
          host_platform: host_platform,
        }
        payload[:properties].merge! additional
      end
      payload
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
  end
end
