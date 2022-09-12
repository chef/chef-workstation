class PoliciesController < ApplicationController

    def install
        @policyItem = Policy.install_policy_file
        render json: @policyItem
    end
end