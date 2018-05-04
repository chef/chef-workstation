require "chef-workstation/target_host"
require "chef-workstation/error"

module ChefWorkstation
  class TargetResolver
    # IDeally, we'd base this on the actual current screen height
    MAX_EXPANDED_TARGETS = 24

    def initialize(unparsed_target, conn_options)
      @unparsed_target = unparsed_target
      @split_targets = unparsed_target.split(",")
      @conn_options = conn_options
    end

    # This will expand the unparsed targets
    def targets
      return @targets unless @targets.nil?
      hostnames = []
      @split_targets.each do |target|
        hostnames = (hostnames | expand_targets(target))
      end
      @targets = hostnames.map { |host| TargetHost.new(host, @conn_options) }
    end

    def expand_targets(target)
      @current_target = target # Hold onto this for error reporting
      do_parse([target.downcase])
    end

    private

    # A string matching PREFIX[x:y]POSTFIX:
    # POSTFIX can contain further ranges itself
    # $1 - prefix; $2 - x, $3 - y, $4 unproccessed/remaining text
    TARGET_WITH_RANGE = /^([a-zA-Z0-9@\/:._-]*)\[([\p{Alnum}]+):([\p{Alnum}]+)\](.*)/

    def do_parse(targets, depth = 0)
      if depth > 2
        raise TooManyRanges.new(@current_target)
      end
      new_targets = []
      done = false
      targets.each do |target|
        if TARGET_WITH_RANGE =~ target
          # $1 - prefix; $2 - x, $3 - y, $4 unprocessed/remaining text
          expand_range(new_targets, $1, $2, $3, $4)
        else
          done = true
          new_targets << target
        end
      end

      if done
        new_targets
      else
        do_parse(new_targets, depth + 1)
      end
    end

    def expand_range(dest, prefix, start, stop, suffix)
      prefix ||= ""
      suffix ||= ""
      start_is_int = Integer(start) >= 0 rescue false
      stop_is_int = Integer(stop) >= 0 rescue false

      if (start_is_int && !stop_is_int) || (stop_is_int && !start_is_int)
        raise InvalidRange.new(@current_target, "[#{start}:#{stop}]")
      end

      # Ensure range start precedes stop
      if start > stop
        temp = stop; stop = start; start = temp
      end
      Range.new(start, stop).each do |value|
        value = value.downcase
        # Ranges will resolve only numbers and letters,
        # not other ascii characters that happen to fall between.
        if /^[a-z0-9]/ =~ value
          dest << "#{prefix}#{value}#{suffix}"
        end
        # Stop expanding as soon as we go over limit to prevent
        # making the user wait for a massive accidental expansion
        if dest.length > MAX_EXPANDED_TARGETS
          raise TooManyTargets.new(@split_targets.length, MAX_EXPANDED_TARGETS)
        end
      end
    end
    class InvalidRange < ErrorNoLogs
      def initialize(unresolved_target, given_range)
        super("CHEFRANGE001", unresolved_target, given_range)
      end
    end
    class TooManyRanges < ErrorNoLogs
      def initialize(unresolved_target)
        super("CHEFRANGE002", unresolved_target)
      end
    end

    class TooManyTargets < ErrorNoLogs
      def initialize(num_top_level_targets, max_targets)
        super("CHEFRANGE003", num_top_level_targets, max_targets)
      end
    end
  end
end
