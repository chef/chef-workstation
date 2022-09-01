# frozen_string_literal: true

# Use Policy.install_policy_file
# Use Policy.update_policy_file

class Policy < ApplicationRecord
  # include ActiveModel::Model

  require 'chef-cli/policyfile_services/install'

  def self.update_policy_file(policyfile_name = "Policyfile.rb")
    install_policy_file_config(policyfile_name)
    { 'status' => 200, 'message' => 'Success' }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.install_policy_file(policyfile_name = "Policyfile.rb")
    install_policy_file_config(policyfile_name)
    { 'status' => 200, 'message' => 'Success' }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.update_policy_file_config(policyfile_name)
    ChefCLI::PolicyfileServices::Install.new(policyfile: policyfile_name,
                                             ui: ChefCLI::UI.new,
                                             root_dir: Dir.pwd,
                                             overwrite: true,
                                             config: nil).run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end

  def self.install_policy_file_config(policyfile_name)
    ChefCLI::PolicyfileServices::Install.new(policyfile: policyfile_name,
                                             ui: ChefCLI::UI.new,
                                             root_dir: Dir.pwd,
                                             config: nil).run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end
end
