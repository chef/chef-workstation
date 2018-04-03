module ChefWorkstation
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
        ChefWorkstation::Log.send(log_method, msg)
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
