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
module ChefWorkstation
  class Error < StandardError
    attr_reader :id, :params
    attr_accessor :show_stack, :show_log
    def initialize(id, *params)
      @id = id
      @params = params
      @show_log = true
      @show_stack = true
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
    attr_accessor :conn, :contained_exception
    def initialize(e, connection)
      super(e.message)
      @contained_exception = e
      @conn = connection
    end
  end

  # Provides mappings of common errors that we don't explicitly
  # handle, but can offer expanded help text around.
  class StandardErrorResolver
    def self.unwrap_exception(wrapper)
      deps
      show_log = true
      show_stack = true
      case wrapper.contained_exception
      when OpenSSL::SSL::SSLError
        if wrapper.contained_exception.message =~ /SSL.*verify failed.*/
          id = "CHEFNET002"
          show_log = false
          show_stack = false
        end
      when SocketError then id = "CHEFNET001"; show_log = false; show_stack = false
      end
      if id.nil?
        wrapper.contained_exception
      else
        e = ChefWorkstation::Error.new(id, wrapper.contained_exception.message)
        e.show_log = show_log
        e.show_stack = show_stack
        e
      end
    end

    def self.deps
      # Avoid loading additional includes until they're needed
      require "socket"
      require "openssl"
    end
  end

end
