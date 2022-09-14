# frozen_string_literal: true

class Cookbook < ApplicationRecord
  require 'chef/knife/cookbook_upload'
  require 'chef/knife/configure'
  require 'chef/application'
  require 'mixlib/cli'

  include Mixlib::CLI

  def self.cookbook_upload(cookbook_name, cookbook_path, config_file = nil)
    cookbook_upload_config(cookbook_name, cookbook_path, config_file)
    { 'status' => 200, 'message' => 'Success' }
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
end
