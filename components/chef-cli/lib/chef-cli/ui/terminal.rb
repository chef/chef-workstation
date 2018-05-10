require "tty-spinner"
require "chef-cli/status_reporter"
require "chef-cli/config"
require "chef-cli/log"
require "chef-cli/ui/plain_text_element"

module ChefCLI
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

        def render_parallel_jobs(header, actions, prefix: "")
          multispinner = TTY::Spinner::Multi.new("[:spinner] #{header}")
          actions.each do |a|
            multispinner.register(":spinner #{a.prefix} :status") do |spinner|
              reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
              a.run(reporter)
            end
          end
          multispinner.auto_spin
        end

        # TODO update this to accept a job instead of a block, for consistency of usage
        #      between render_job and render_parallel
        def render_job(msg, prefix: "", &block)
          klass = ChefCLI::UI.const_get(ChefCLI::Config.dev.spinner)
          spinner = klass.new("[:spinner] :prefix :status", output: @location)
          reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
          reporter.update(msg)
          spinner.run { yield(reporter) }
        end
      end
    end
  end
end
