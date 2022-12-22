
module Api
  module V1
    class PoliciesController < ApiV1Controller

      def push
        @policy_item = Policy.push_policy_file(params[:directory_path])
        render json: @policy_item
      rescue StandardError => e
        render json: { message: e.message , code: "422" }, status: 422
      end

      def install
        @policy_item = Policy.install_policy_file(params[:directory_path])
        render json: @policy_item
      rescue StandardError => e
        render json: { message: e.message , code: "422" }, status: 422
      end

    end
  end
end
