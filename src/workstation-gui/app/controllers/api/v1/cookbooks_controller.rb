# frozen_string_literal: true

module Api
  module V1
    class CookbooksController < ApiV1Controller

      def create
        cookbook_upload = Cookbook.cookbook_upload(upload_params[:cookbook_name],
                                                   upload_params[:cookbook_path],
                                                   upload_params[:config_file])

        render json: cookbook_upload, status: upload_status(cookbook_upload)
      end

      def cookbooks
        cookbooks_list = Cookbook.get_repository_list(params)
        result, total_size = Cookbook.fetch_cookbooks(cookbooks_list, params)
        render json: { cookbooks: result, total_size: total_size, message: "success", code: "200" }, status: 200

      rescue StandardError => e
        render json: { message: e.message, code: "422" }, status: 422
      end

      private

      def upload_params
        params.require(:cookbook).permit(:config_file, :cookbook_name, :cookbook_path)
      end

      def upload_status(response)
        return :unprocessable_entity unless response["code"] == 200

        :ok
      end
    end
  end
end
