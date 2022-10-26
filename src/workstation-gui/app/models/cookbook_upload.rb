# frozen_string_literal: true

# Use CookbookUpload.cookbook_upload
class CookbookUpload < ApplicationRecord
  require "chef/knife/cookbook_upload"
  require "chef/knife/configure"
  require "chef/application"
  require "mixlib/cli"

  include Mixlib::CLI
  include ActiveModel::Model

  def self.cookbook_upload(cookbook_name, config_file = nil)
    cookbook_upload_config(cookbook_name, config_file)
    { "status" => 200, "message" => "Success" }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.cookbook_upload_config(cookbook_name, config_file)
    # Knife check for default location
    unless config_file.nil?
      @app = Chef::Application.new
      @app.config[:config_file] = config_file
      @app.configure_chef
    end
    Chef::Knife::CookbookUpload.load_deps
    k = Chef::Knife::CookbookUpload.new
    k.name_args = [cookbook_name]
    k.run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end
end
