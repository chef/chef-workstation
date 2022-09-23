# frozen_string_literal: true

class Cookbook < ApplicationRecord
  require "chef/knife/cookbook_upload"
  require "chef/knife/configure"
  require "chef/application"
  require "mixlib/cli"

  include Mixlib::CLI
  extend Workstation::Workable

  def self.cookbook_upload(cookbook_name, cookbook_path, config_file = nil)
    cookbook_upload_config(cookbook_name, cookbook_path, config_file)
    { "status" => 200, "message" => "Success" }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.cookbook_upload_config(cookbook_name, cookbook_path, config_file = nil)
    @app = Chef::Application.new
    @app.config[:config_file] = config_file || "#{Dir.home}/.chef/config.rb"
    @app.configure_chef

    Chef::Knife::CookbookUpload.load_deps
    Chef::Config[:cookbook_path] = cookbook_path
    k = Chef::Knife::CookbookUpload.new
    k.name_args = [cookbook_name]
    k.run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end

  def self.fetch_cookbooks(cookbooks_list, params)
    result = []
    cookbooks_list.each do |list|
      result << add_cookbooks_details(list)
    end
    cb_list =  result.flatten
    total_size = cb_list.size
    result = result_post_pagination(cb_list, params[:limit], params[:page], total_size)
    [result, total_size]
  end

  def self.get_repository_list(params)
    data_hash =  parse_file(read_repo_file)
    if params[:repo_path].present?
      data_hash["repositories"].select { |data| data["filepath"] == params[:repo_path] } # todo - retrun exception incase wrong id
    elsif params[:repo_id].present?
      data_hash["repositories"].select { |data| data["id"] == params[:repo_id] }
    else
      data_hash["repositories"]
    end
  end

  def self.add_cookbooks_details(list)
    path = list["filepath"]
    repository_name = list["repository_name"]
    return [] unless valid_path_structure(path, "cookbooks")

    filepath = File.join(path , "cookbooks")
    cb_list = Dir.entries(filepath).select { |f| File.directory?( File.join(filepath , f)) }
    cb_list -= [".", "..", "..."]
    cb_list.map! do |val|
      {
      cookbook_name: val,
      filepath: File.join(filepath, val),
      repository:  repository_name,
      actions_available: ["upload"],
      recipe_count: get_recipe_count(File.join(filepath, val)),
      policyfile: get_policy_file(File.join(filepath, val)),
    }
    end
  end
end
