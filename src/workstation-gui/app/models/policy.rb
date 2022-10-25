# frozen_string_literal: true

# Use Policy.install_policy_file
# Use Policy.update_policy_file

class Policy < ApplicationRecord
  # include ActiveModel::Model

  require "chef-cli/policyfile_services/install"
  require "chef-cli/policyfile_services/push"
  require "chef-cli/configurable"

  class CLIConfig
    include ChefCLI::Configurable
    def config
      {}
    end
  end

  def self.update_policy_file(policyfile_name = "Policyfile.rb")
    install_policy_file_config(policyfile_name)
    { "status" => 200, "message" => "Success" }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.install_policy_file(directory_path)
    install_policy_file_config("Policyfile.rb", directory_path)
    { "status" => 200, "message" => "Success" }
  rescue StandardError => e
    JSON.parse(e.message)
  end

  def self.push_policy_file(directory_path)
    install_push_file_config(CLIConfig.new.chef_config, "Policyfile.rb", directory_path)
    { "status" => 200, "message" => "Success" }
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

  def self.install_policy_file_config(policyfile_name, directory_path)
    ChefCLI::PolicyfileServices::Install.new(policyfile: policyfile_name,
                                             ui: ChefCLI::UI.new,
                                             root_dir: directory_path || Dir.pwd,
                                             config: nil).run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end

  def self.install_push_file_config(chef_config, policyfile_name, directory_path)
    ChefCLI::PolicyfileServices::Push.new(policyfile: policyfile_name,
                                          ui: ChefCLI::UI.new,
                                          policy_group: "Policyfile.lock.json",
                                          config: chef_config,
                                          root_dir: directory_path || Dir.pwd).run
  rescue StandardError => e
    raise Exceptions::UnprocessableEntityAPI, e
  end
end
