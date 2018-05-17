require "rspec/matchers/built_in/output"
require "chef-run/ui/terminal"

# Custom behavior for the builtin output matcher
# to allow it to handle to_terminal, which integrates
# with our UI::Terminal interface.
module RSpec
  module Matchers
    module BuiltIn
      class Output < BaseMatcher
        # @api private
        # Provides the implementation for `output`.
        # Not intended to be instantiated directly.
        def to_terminal
          @stream_capturer = CaptureTerminal
          self
        end
        module CaptureTerminal
          def self.name
            "terminal"
          end

          def self.capture(block)
            captured_stream = StringIO.new
            original_stream = ::ChefRun::UI::Terminal.location
            ::ChefRun::UI::Terminal.location = captured_stream
            block.call
            captured_stream.string
          ensure
            ::ChefRun::UI::Terminal.location = original_stream
          end
        end
      end
    end
  end
end
