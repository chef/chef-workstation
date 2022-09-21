#
# Copyright:: Copyright Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class Api::V1::CookbooksController < ApplicationController
  # before_action :validate_creds, only: %i[login]
  # skip_before_action :authenticate_api_requests!, only: %i[login]
  include WorkstationHelper

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

  def validate_creds
    render json: { errors: "Access key is required" } unless params.key?(:access_key)
  end
end