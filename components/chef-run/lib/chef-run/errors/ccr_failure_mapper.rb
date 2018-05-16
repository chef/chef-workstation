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

require "chef-run/error"

module ChefRun::Errors
  class CCRFailureMapper
    attr_reader :params

    def initialize(exception, params)
      @params = params
      @cause_line = exception
    end

    def raise_mapped_exception!
      if @cause_line.nil?
        raise RemoteChefRunFailedToResolveError.new(params[:stdout], params[:stderr])
      else
        errid, *args = exception_args_from_cause()
        if errid.nil?
          raise RemoteChefClientRunFailedUnknownReason.new()
        else
          raise RemoteChefClientRunFailed.new(errid, *args)
        end

      end
    end

    # Ideally we will write a custom handler to package up data we care
    # about and present it more directly  https://docs.chef.io/handlers.html
    # For now, we'll just match the most common failures based on their
    # messages.
    def exception_args_from_cause
      # Ordering is important below.  Some earlier tests are more detailed
      # cases of things that will match more general tests further down.
      case @cause_line
      when /.*had an error:(.*:)\s+(.*$)/
        # Some invalid property value cases, among others.
        ["CHEFCCR002", $2]
      when /.*Chef::Exceptions::ValidationFailed:\s+Option action must be equal to one of:\s+(.*)!\s+You passed :(.*)\./
        # Invalid action - specialization of invalid property value, below
        ["CHEFCCR003", $2, $1]
      when /.*Chef::Exceptions::ValidationFailed:\s+(.*)/
        # Invalid resource property value
        ["CHEFCCR004", $1]
      when /.*NameError: undefined local variable or method `(.+)' for cookbook.+/
        # Invalid resource type in most cases
        ["CHEFCCR005", $1]
      when /.*NoMethodError: undefined method `(.+)' for cookbook.+/
        # Invalid resource type in most cases
        ["CHEFCCR005", $1]
      when /.*undefined method `(.*)' for (.+)/
        # Unknown resource property
        ["CHEFCCR006", $1, $2]

      # Below would catch the general form of most errors, but the
      # message itself in those lines is not generally aligned
      # with the UX we want to provide.
      # when /.*Exception|Error.*:\s+(.*)/
      else
        nil
      end
    end

    class RemoteChefClientRunFailed < ChefRun::ErrorNoLogs
      def initialize(id, *args); super(id, *args); end
    end

    class RemoteChefClientRunFailedUnknownReason < ChefRun::ErrorNoStack
      def initialize(); super("CHEFCCR099"); end
    end

    class RemoteChefRunFailedToResolveError < ChefRun::ErrorNoStack
      def initialize(stdout, stderr); super("CHEFCCR001", stdout, stderr); end
    end

  end

end
