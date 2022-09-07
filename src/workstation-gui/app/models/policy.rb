# frozen_string_literal: true

# Use Policy.install_policy_file
# Use Policy.update_policy_file

class Policy < ApplicationRecord
  # include ActiveModel::Model

  require 'chef-cli/policyfile_services/install'
  require 'chef-cli/policyfile_services/push.rb'
  require 'chef-cli/configurable.rb'

  class CLIConfig
    include ChefCLI::Configurable
  end


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

  def self.push_policy_file
    # require 'pry'
    # binding.pry
    install_push_file_config(CLIConfig.new.chef_config, policyfile_name = "Policyfile.rb")
    { 'status' => 200, 'message' => 'Success' }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  private

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

  def self.install_push_file_config(chef_config, policyfile_name)
    ChefCLI::PolicyfileServices::Push.new(policyfile: policyfile_name,
                                          ui: ChefCLI::UI.new,
                                          policy_group: "Policyfile.lock.json",
                                          config: chef_config,
                                          root_dir: Dir.pwd).run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end
end
