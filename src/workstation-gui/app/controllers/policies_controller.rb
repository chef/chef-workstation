class PoliciesController < ApplicationController

    def create
      ec = Encoding::Converter.new("ISO-8859-1", "EUC-JP")
      begin
        ec.convert("\xa0")
        @policyItem = Policy.install_policy_file
        render json: @policyItem
      rescue Encoding::UndefinedConversionError
        puts $!.error_char.dump
        p $!.error_char.encoding
      end
    end

    def push
      @policyItem = Policy.push_policy_file
      render json: @policyItem
    end
end