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

require "tty-spinner"
require "chef-run/status_reporter"
require "chef-run/config"
require "chef-run/log"
require "chef-run/ui/plain_text_element"

module ChefRun
  module UI
    class Terminal
      class Job
        attr_reader :proc, :prefix, :target_host, :exception
        def initialize(prefix, target_host, &block)
          @proc = block
          @prefix = prefix
          @target_host = target_host
          @error = nil
        end

        def run(reporter)
          @proc.call(reporter)
        rescue => e
          reporter.error(e.to_s)
          @exception = e
        end
      end

      class << self
        # To support matching in test
        attr_accessor :location

        def init(location)
          @location = location
          # In Ruby 2.5+ threads print out to stdout when they raise an exception. This is an agressive
          # attempt to ensure debugging information is not lost, but in our case it is not necessary
          # because we handle all the errors ourself. So we disable this to keep output clean.
          # See https://ruby-doc.org/core-2.5.0/Thread.html#method-c-report_on_exception
          Thread.report_on_exception = false
        end

        def write(msg)
          @location.write(msg)
        end

        def output(msg)
          @location.puts msg
        end

        def render_parallel_jobs(header, jobs)
          multispinner = TTY::Spinner::Multi.new("[:spinner] #{header}", output: @location)
          jobs.each do |a|
            multispinner.register(spinner_prefix(a.prefix)) do |spinner|
              reporter = StatusReporter.new(spinner, prefix: a.prefix, key: :status)
              a.run(reporter)
            end
          end
          multispinner.auto_spin
        end

        # TODO update this to accept a job instead of a block, for consistency of usage
        #      between render_job and render_parallel
        def render_job(msg, prefix: "", &block)
          klass = ChefRun::UI.const_get(ChefRun::Config.dev.spinner)
          spinner = klass.new(spinner_prefix(prefix), output: @location)
          reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
          reporter.update(msg)
          spinner.run { yield(reporter) }
        end

        def spinner_prefix(prefix)
          spinner_msg = "[:spinner] "
          spinner_msg += ":prefix " unless prefix.empty?
          spinner_msg + ":status"
        end
      end
    end
  end
end
