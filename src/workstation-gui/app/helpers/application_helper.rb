module ApplicationHelper
  def chef_dir
    File.expand_path("~/.chef") # todo move this file in .chef string in module with constants
  end
  def chef_repo_storage_file
    File.expand_path(File.join(chef_dir, 'repository.json'))
  end

  def create_chef_repo_storage_file
    File.new(chef_repo_storage_file)
    chef_repo_storage_file
  end

  def generate_random_id
    require 'securerandom'
    uuid = SecureRandom.uuid
  end


end
