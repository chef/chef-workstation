
module Api
  module V1
    class PoliciesController < ApiV1Controller

      def push
        @policyItem = Policy.push_policy_file(directory_path = params[:directory_path])
        render json: @policyItem
      rescue StandardError => e
        render json: { message: e.message , code: "422" }, status: 422
      end

      def install
        @policyItem = Policy.install_policy_file(directory_path = params[:directory_path])
        render json: @policyItem
      rescue StandardError => e
        render json: { message: e.message , code: "422" }, status: 422
      end

    end
  end
end
