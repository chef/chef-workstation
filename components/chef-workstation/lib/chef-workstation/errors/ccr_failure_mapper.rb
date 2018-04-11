require "chef-workstation/error"

module ChefWorkstation::Errors
  class CCRFailureMapper
    attr_reader :params

    def initialize(stack, params)
      @params = params
      @cause_line = stack[1]
    end

    def raise_mapped_exception!
      if @cause_line.nil?
        raise RemoteChefRunFailedToResolveError.new(@params[:stdout], @params[:stderr])
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
        ["CHEFCCR002", $2, resource_doc_anchor]
      when /.*Chef::Exceptions::ValidationFailed:\s+Option action must be equal to one of:\s+(.*). You passed :(.*)\./
        # Invalid action - specialization of invalid property value, below
        ["CHEFCCR003", params[:resource], $2, $1, resource_doc_anchor()]
      when /.*Chef::Exceptions::ValidationFailed:\s+(.*)/
        # Invalid resource property value
        ["CHEFCCR004", $1, params[:resource], resource_doc_anchor()]
      when /.*NoMethodError: undefined method `#{params[:resource]}'.*/
        # Invalid resource type in most cases
        ["CHEFCCR005", params[:resource]]
      when /.*undefined method `(.*)'.*for Chef::Resource.*/
        # Unknown resource property
        ["CHEFCCR006", $1, params[:resource], resource_doc_anchor()]

      # Below would catch the general form of most errors, but the
      # message itself in those lines is not generally aligned
      # with the UX we want to provide.
      # when /.*Exception|Error.*:\s+(.*)/
      else
        nil
      end
    end

    def resource_doc_anchor
      params[:resource].
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("_", "-").
        downcase
    end

    class RemoteChefClientRunFailed < ChefWorkstation::ErrorNoLogs
      def initialize(id, *args); super(id, *args); end
    end

    class RemoteChefClientRunFailedUnknownReason < ChefWorkstation::ErrorNoStack
      def initialize(); super("CHEFCCR099"); end
    end

    class RemoteChefRunFailedToResolveError < ChefWorkstation::ErrorNoStack
      def initialize(stdout, stderr); super("CHEFCCR001", stdout, stderr); end
    end

  end

end
