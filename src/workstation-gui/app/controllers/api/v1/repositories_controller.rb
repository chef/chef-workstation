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
class Api::V1::RepositoriesController < ApiV1Controller
  include Workstation::Workable

  before_action :create_repository_repository, only: [:link_repository]

  # todo move extra code to service, to improve it
  def repositories
    data_hash = parse_file(read_repo_file)
    repo_list = data_hash["repositories"]
    result = result_post_pagination(repo_list, params[:limit], params[:page], repo_list.size)
    render json: { repositories: result, total_size: repo_list.size, message: "success", code: "200" }, status: 200

  rescue StandardError => e
    render json: { message: e.message , code: "422" }, status: 422
  end

  def link_repository
    require "json"
    check_for_duplicate_linking # todo can move these to service
    write_new_path_to_file
    render json: { status: "ok", message: "success", code: "200" }, status: 200

  rescue StandardError => e
    render json: { message: e.message , code: "422" }, status: 422
  end

  private

  def check_for_duplicate_linking
    unless read_repo_file.empty?
      data_hash = parse_file(read_repo_file)
      if data_hash["repositories"].any? { |h| h["filepath"] == repository_params["filepath"] } # todo make sure to use sym, for better code quality ex h[:filepath], jspn is not reading symbol
        raise StandardError.new("Repository already linked")
      end
    end
  end

  def write_new_path_to_file
    temp_hash = {
      "id" => repository_params[:id],
      "type" => repository_params[:type],
      "repository_name" => repository_params[:repository_name],
      "filepath" => repository_params[:filepath],
    }

    data_hash =  parse_file(read_repo_file)
    data_hash["repositories"] << temp_hash
    File.open(chef_repo_storage_file, "w") do |f|
      f.write(data_hash.to_json)
    end
  end

  def create_repository_repository
    unless File.exist?(chef_repo_storage_file)
      create_chef_repo_storage_file
    end
    true
  end

  def get_repo_name(file_path)
    file_path.split("/").last # todo handle case for windows aswell.
  end

  def repository_params
    raise StandardError.new("Invalid repository path")  unless validate_dir_path(params[:repositories][:filepath])

    params[:repositories][:id] = generate_random_id if  params[:repositories][:id].nil?
    params[:repositories][:repository_name] = get_repo_name( params[:repositories][:filepath] ) if params[:repositories][:repository_name].nil?
    params.require(:repositories).permit(:id, :repository_name, :filepath, :type)
  end
end