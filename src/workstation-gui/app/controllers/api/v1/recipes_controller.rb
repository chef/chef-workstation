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
class Api::V1::RecipesController < ApiV1Controller

  include Workstation::Workable

  def recipes
    path = params[:filepath]
    raise StandardError.new("Filepath for recipe is not given") if path.nil?
    raise StandardError.new("Not valid Cookbook structure, need to have Recipes") unless valid_path_structure(path, "recipes")

    filepath = File.join(path , "recipes")
    cb_list = Dir.entries(filepath).select { |f| File.file?( File.join(filepath , f)) }
    count = cb_list.size
    result  = result_post_pagination( cb_list, params[:limit], params[:page], count)
    render json: { recipes: result, count: count,  message: "success", code: "200" }, status: 200

  rescue StandardError => e
    render json: { message: e.message , code: "422" }, status: 422
  end
end