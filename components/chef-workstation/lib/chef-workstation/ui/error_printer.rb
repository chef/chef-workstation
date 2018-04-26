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
require "train/errors"
require "pastel"
require "chef-workstation/error"
require "chef-workstation/config"
require "chef-workstation/text"
require "chef-workstation/ui/terminal"

module ChefWorkstation::UI
  class ErrorPrinter
    attr_reader :pastel, :show_log, :show_stack, :exception, :target_host
    # TODO define 't' as a method is a temporary workaround
    # to ensure that text key lookups are testable.
    def t
      ChefWorkstation::Text.errors
    end

    DEFAULT_ERROR_NO = "CHEFINT001"

    def self.show_error(e)
      unwrapped = ChefWorkstation::StandardErrorResolver.unwrap_exception(e)
      formatter = ErrorPrinter.new(e, unwrapped)
      Terminal.output(formatter.format_error)
    rescue => e
      dump_unexpected_error(e)
    end

    def self.write_backtrace(e, args)
      formatter = ErrorPrinter.new(e)
      out = StringIO.new
      formatter.add_backtrace_header(out, args)
      formatter.add_formatted_backtrace(out)
      formatter.save_backtrace(out)
    rescue => ex
      dump_unexpected_error(ex)
    end

    # Use this to dump an an exception to output. useful
    # if an error occurs in the error handling itself.
    def self.dump_unexpected_error(e)
      Terminal.output "INTERNAL ERROR"
      Terminal.output "-=" * 30
      Terminal.output "Message:"
      Terminal.output e.message
      Terminal.output e.backtrace if e.respond_to?(:backtrace)
      Terminal.output "Backtrace:"
      Terminal.output "=-" * 30
    end

    def initialize(wrapper, unwrapped = nil, target_host = nil)
      @exception = unwrapped || wrapper.contained_exception
      @target_host = wrapper.target_host || target_host
      @pastel = Pastel.new
      @show_log = exception.respond_to?(:show_log) ? exception.show_log : true
      @show_stack = exception.respond_to?(:show_stack) ? exception.show_stack : true
      @content = StringIO.new
      @command = exception.respond_to?(:command) ? exception.command : nil
      @id = DEFAULT_ERROR_NO
      if exception.respond_to?(:id) && exception.id =~ /CHEF.*/
        @id = exception.id
      end
      if exception.respond_to?(:decorate)
        @decorate = exception.decorate
      else
        @decorate = true
      end
    rescue => e
      ErrorPrinter.dump_unexpected_error(e)
      exit! 128
    end

    def format_error
      if @decorate
        format_decorated
      else
        format_undecorated
      end
      @content.string
    end

    def format_undecorated
      @content << "\n"
      @content << format_body()
      if @command
        @content << "\n"
        @content << @command.usage
      end
    end

    def format_decorated
      @content << "\n"
      @content << format_header()
      @content << "\n\n"
      @content << format_body()
      @content << "\n"
      @content << format_footer()
      @content << "\n"
    end

    def format_header
      pastel.decorate(@id, :bold)
    end

    def format_body
      if exception.kind_of? ChefWorkstation::Error
        format_workstation_exception
      elsif exception.kind_of? Train::Error
        format_train_exception
      else
        format_other_exception
      end
    end

    def format_footer
      if show_log
        if show_stack
          t.footer.both(ChefWorkstation::Config.log.location,
                        ChefWorkstation::Config.stack_trace_path)
        else
          t.footer.log_only(ChefWorkstation::Config.log.location)
        end
      else
        if show_stack
          t.footer.stack_only
        else
          t.footer.neither
        end
      end
    end

    def add_backtrace_header(out, args)
      out.write("\n#{"-" * 80}\n")
      out.print("#{Time.now}: Error encountered while running the following:\n")
      out.print("  #{args.join(' ')}\n")
      out.print("Backtrace:\n")
    end

    def save_backtrace(output)
      File.open(ChefWorkstation::Config.stack_trace_path, "ab+") do |f|
        f.write(output.string)
      end
    end

    def format_workstation_exception
      params = exception.params
      t.send(@id, *params)
    end

    def format_train_exception
      backend, host = formatted_host()
      if host.nil?
        t.CHEFTRN002(exception.message)
      else
        t.CHEFTRN001(backend, host, exception.message)
      end
    end

    def format_other_exception
      t.send(DEFAULT_ERROR_NO, exception.message)
    end

    def formatted_host
      return nil if target_host.nil?
      cfg = target_host.config
      port = cfg[:port].nil? ? "" : ":#{cfg[:port]}"
      if cfg[:user].nil?
        user = ""
      else
        if cfg[:password].nil?
          user = "#{config[:user]}@"
        else
          user = "#{config[:user]}:<password-hidden>@"
        end
      end
      "#{user}#{config[:host]}#{port}"
    end

    # mostly copied from
    # https://gist.github.com/stanio/13d74294ca1868fed7fb
    def add_formatted_backtrace(out)
      _format_single(out, exception)
      current_backtrace = exception.backtrace
      cause = exception.cause
      until cause.nil?
        cause_trace = _unique_trace(cause.backtrace.to_a, current_backtrace)
        out.print "Caused by: "
        _format_single(out, cause, cause_trace)
        backtrace_length = cause.backtrace.length
        if backtrace_length > cause_trace.length
          out.print "\t... #{backtrace_length - cause_trace.length} more"
        end
        current_backtrace = cause.backtrace
        cause = cause.cause
      end
    end

    def _format_single(out, exception, backtrace = nil)
      out.puts "#{exception.class}: #{exception.message}"
      backtrace ||= exception.backtrace.to_a
      backtrace.each { |trace| out.puts "\t#{trace}" }
    end

    def _unique_trace(backtrace1, backtrace2)
      i = 1
      while i <= backtrace1.size && i <= backtrace2.size
        break if backtrace1[-i] != backtrace2[-i]
        i += 1
      end
      backtrace1[0..-i]
    end
  end

end
