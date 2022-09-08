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
class Api::V1::RepositoriesController < ApplicationController
  # before_action :validate_creds, only: %i[login]
  # skip_before_action :authenticate_api_requests!, only: %i[login]
  before_action :create_repository_repository

  def repositories
    render json: {status: "okay", message: "success" }
  end

  def link_repository(repository_params)
    require 'json'
    check_for_duplicate_linking # todo can move these to service
    write_new_path_to_file
  end

  private

  def check_for_duplicate_linking
    data_hash = JSON.parse(read_repo_file)
    data_hash[0][:repositories]
    if data_hash[0][:repositories].any? {|h| h[:filepath] == repository_params[:filepath]}
      render json: {status: "422", message: "Repository already linked" } and return
    end
  end

  def write_new_path_to_file
    tempHash = {
      "id" => repository_params[:id],
      "repository_name" => repository_params[:repository_name],
      "cookbooks" => repository_params[:cookbooks],
      "filepath" => repository_params[:filepath]
    }
    File.open(chef_repo_storage_file,"w") do |f|
      f.write(tempHash.to_json)
    end
  end

  def read_repo_file
     File.read(chef_repo_storage_file)
  end

  def  create_repository_repository
    unless File.exist?(chef_repo_storage_file)
      create_chef_repo_storage_file
    end
    true
  end

  def validate_creds
    render json: { errors: "Access key is required"} unless params.key?(:access_key)
  end

  def get_repo_name(file_path)
    file_path.split("/").last  # todo handle case for windows aswell.
  end

  def repository_params
    params[:repositories][:id] = generate_random_id if  params[:repositories][:id].nil?
    params[:repositories][:cookbooks] = [] if  params[:repositories][:cookbooks].nil?
    params[:repositories][:repository_name] = get_repo_name( params[:repositories][:filepath] )if  params[:repositories][:cookbooks].nil?
    params.require(:repositories).permit(:id, :repository_name, :cookbooks, :filepath)
  end
end