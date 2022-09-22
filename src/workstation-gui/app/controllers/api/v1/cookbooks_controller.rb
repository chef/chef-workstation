
# frozen_string_literal: true
module Api
  module V1
    class CookbooksController < ApplicationController

      include WorkstationHelper

      before_action :authenticate_api_requests!
      before_action :validate_params

      def create
        cookbook_upload = Cookbook.cookbook_upload(upload_params[:cookbook_name],
                                                   upload_params[:cookbook_path],
                                                   upload_params[:config_file])
        render json: { status: cookbook_upload }
      end

      def cookbooks
        cookbooks_list = get_repository_list
    
        result = []
        cookbooks_list.each do |list|
          result << add_cookbooks_details(list)
        end
        result = result_post_pagination( result.flatten, params[:limit], params[:page])
        render json: { cookbooks: result, message: "success", code: "200" }, status: 200
    
      rescue StandardError => e
        render json: { message: e.message , code: "422" }, status: 422
      end

      private

      def get_repository_list
        data_hash =  parse_file(read_repo_file)
        if  params[:repo_path].present?
          data_hash["repositories"].select { |data| data["filepath"] == params[:repo_path] }
        elsif params[:repo_id].present?
          data_hash["repositories"].select { |data| data["id"] == params[:repo_id] }
        else
          data_hash["repositories"]
        end
      end

      def add_cookbooks_details(list)
        path = list["filepath"]
        repository_name = list["repository_name"]
        return [] unless valid_path_structure(path, "cookbooks")
    
        filepath = File.join(path , "cookbooks")
        cb_list = Dir.entries(filepath).select { |f| File.directory?( File.join(filepath , f)) }
        cb_list -= [".", "..", "..."]
        cb_list.map! do |val| {
          cookbook_name: val,
          filepath: File.join(filepath, val),
          repository:  repository_name,
          actions_available: ['upload'],
          recipe_count: get_recipe_count(File.join(filepath, val)),
          policyfile: get_policy_file(File.join(filepath, val))
        }
        end # todo move this to cookbook service
      end

      def upload_params
        params.require(:cookbook).permit(:config_file, :cookbook_name, :cookbook_path)
      end

      def validate_params
        unless params.key?(:cookbook_name) || params.key?(:cookbook_path)
          render json: { message: 'unprocessable entity', status: 422 },
                 status: 422
        end
      end
    end
  end
end
