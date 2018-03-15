require "chef-workstation/status_reporter"
require "tty-spinner"

module ChefWorkstation
  module UI
    class Terminal
      class << self

        def init(location = STDOUT)
          @location = location
        end

        def output(msg)
          @location.puts msg
        end

        def spinner(msg, prefix: "", &block)
          spinner = TTY::Spinner.new("[:spinner] :prefix :status", output: @location)
          reporter = StatusReporter.new(spinner, prefix: prefix, key: :status)
          reporter.update(msg)
          spinner.run { yield(reporter) }
        end

      end
    end
  end
end
