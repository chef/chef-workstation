# frozen_string_literal: true

module Exceptions
  class UnprocessableEntityAPI < StandardError
    def initialize(msg, exception_type = "API exception")
      @exception_type = exception_type
      super({ message: msg, code: 422 }.to_json)
    end
  end
end