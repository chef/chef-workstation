class PoliciesController < ApplicationController

    def create
        @policyItem = Policy.install_policy_file
        render json: @policyItem
    end
end