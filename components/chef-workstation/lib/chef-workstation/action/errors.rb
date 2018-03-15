module ChefWorkstation
  module Action
    module Errors
      class ActionError < RuntimeError
        attr_reader :id, :params
        def initialize(id, *params)
           @id = id
           @params = params
        end
      end
      class UnsupportedTargetOS < ActionError
        def initialize(os_name) ; super("ACT001", os_name) ; end
      end

    end
  end
end







