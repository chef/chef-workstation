class PoliciesController < ApplicationController

    def install
        @policyItem = Policy.install_policy_file
        render json: @policyItem
    end

    def push
      @policyItem = Policy.push_policy_file
      render json: @policyItem
    end
end