require "tty-spinner"
require "chef-workstation/status_reporter"
require "chef-workstation/config"
require "chef-workstation/log"
require "chef-workstation/ui/plain_text_element"

module ChefWorkstation
  module UI
    class Terminal
      class Job
        attr_reader :proc, :prefix, :target_host, :exception
        def initialize(prefix, target_host, initial_message = nil, &block)
          @proc = block
          @prefix = prefix
          @target_host = target_host
          @initial_message = initial_message
          @exception = nil
        end

        def run(reporter)
          reporter.update(initial_message)
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

        def render_parallel_jobs(header, jobs, prefix: "")
          multispinner = TTY::Spinner::Multi.new("[:spinner] #{header}")
          jobs.each do |j|
            multispinner.register(":spinner #{j.prefix} :status") do |spinner|
              reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
              j.run(reporter)
            end
          end
          multispinner.auto_spin
        end

        def render_job(prefix, job, reporter = nil)
          klass = ChefWorkstation::UI.const_get(ChefWorkstation::Config.dev.spinner)
          spinner = klass.new("[:spinner] :prefix :status", output: @location)
          reporter ||= StatusReporter.new(spinner, prefix: prefix, key: :status)
          spinner.run { job.run(reporter) }
        end
      end
    end
  end
end
