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

module ChefRun
  module UI
    class PlainTextElement
      def initialize(format, opts)
        @orig_format = format
        @format = format
        @output = opts[:output]
      end

      def run(&block)
        yield
      end

      def update(params)
        # SOme of this is particular to our usage -
        # prefix does not cause a text update, but does
        # change the prefix for future messages.
        if params.has_key?(:prefix)
          @format = @orig_format.gsub(":prefix", params[:prefix])
          return
        end

        if @succ
          ind = "OK"
          @succ = false
          log_method = :info
        elsif @err
          ind = "ERR"
          @err = false
          log_method = :error
        else
          log_method = :debug
          ind = " - "
        end

        # Since this is a generic type, we can replace any component
        # name in this regex - but for now :spinner is the only component
        # we're standing in for.
        msg = @format.gsub(/:spinner/, ind)
        params.each_pair do |k, v|
          msg.gsub!(/:#{k}/, v)
        end
        ChefRun::Log.send(log_method, msg)
        @output.puts(msg)
      end

      def error
        @err = true
        @succ = false
      end

      def success
        @succ = true
        @err = false
      end
    end
  end
end
