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
  class Error < StandardError
    attr_reader :id, :params
    attr_accessor :show_stack, :show_log, :decorate
    def initialize(id, *params)
      @id = id
      @params = params || []
      @show_log = true
      @show_stack = true
      @decorate = true
    end
  end

  class ErrorNoLogs < Error
    def initialize(id, *params)
      super
      @show_log = false
      @show_stack = false
    end
  end

  class ErrorNoStack < Error
    def initialize(id, *params)
      super
      @show_log = true
      @show_stack = false
    end
  end

  class WrappedError < StandardError
    attr_accessor :target_host, :contained_exception
    def initialize(e, target_host)
      super(e.message)
      @contained_exception = e
      @target_host = target_host
    end
  end

  class MultiJobFailure < ChefRun::ErrorNoLogs
    attr_reader :jobs
    def initialize(jobs)
      super("CHEFMULTI001")
      @jobs = jobs
      @decorate = false
    end
  end

  # Provides mappings of common errors that we don't explicitly
  # handle, but can offer expanded help text around.
  class StandardErrorResolver

    def self.resolve_exception(exception)
      deps
      show_log = true
      show_stack = true
      case exception
      when OpenSSL::SSL::SSLError
        if exception.message =~ /SSL.*verify failed.*/
          id = "CHEFNET002"
          show_log = false
          show_stack = false
        end
      when SocketError then id = "CHEFNET001"; show_log = false; show_stack = false
      end
      if id.nil?
        exception
      else
        e = ChefRun::Error.new(id, exception.message)
        e.show_log = show_log
        e.show_stack = show_stack
        e
      end
    end

    def self.wrap_exception(original, target_host = nil)
      resolved_exception = resolve_exception(original)
      WrappedError.new(resolved_exception, target_host)
    end

    def self.unwrap_exception(wrapper)
      resolve_exception(wrapper.contained_exception)
    end

    def self.deps
      # Avoid loading additional includes until they're needed
      require "socket"
      require "openssl"
    end
  end

end
