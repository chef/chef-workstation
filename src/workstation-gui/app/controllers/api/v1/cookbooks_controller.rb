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

  def cookbooks
    cookbooks_list = get_repository_cookbooks
    result = []
    cookbooks_list.each do |list|
      result << list["cookbooks"]
    end
    result = result_post_pagination( result.flatten, params[:limit], params[:page])
    render json: { cookbooks: result, message: "success", code: "200" }, status: 200

  rescue StandardError => e
    render json: { message: e.message , code: "422" }, status: 422
  end

  private

  def get_repository_cookbooks
    data_hash =  parse_file(read_repo_file)
    if params[:repo_id].present?
      data_hash["repositories"].select { |data| data["id"] == params[:repo_id] } # returns all the cookbook if repo_id is not given
    else
      data_hash["repositories"]
    end
  end

  def validate_creds
    render json: { errors: "Access key is required" } unless params.key?(:access_key)
  end
end