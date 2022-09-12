module ApplicationHelper
  DEFAULT_LIMIT = 10
  DEFAULT_PAGE = 1
  def chef_dir
    File.expand_path("~/.chef") # todo move this file in .chef string in module with constants
  end

  def chef_repo_storage_file
    File.expand_path(File.join(chef_dir, "repository.json"))
  end

  def create_chef_repo_storage_file
    fobj = File.open(chef_repo_storage_file, "w") do |f|
      f.write({ "repositories" => [] }.to_json)
    end
    fobj.close
    chef_repo_storage_file
  end

  def read_repo_file
    File.read(chef_repo_storage_file)
  end

  def parse_file(file_path)
    JSON.parse(file_path)
  end

  def generate_random_id
    require "securerandom"
    uuid = SecureRandom.uuid
  end

  def validate_path(dir_path)
    File.directory?(dir_path)
  end

  def result_post_pagination(array_data, limit, page)
    limit ||= DEFAULT_LIMIT
    page ||= DEFAULT_PAGE
    end_index = page.to_i * limit.to_i
    start_index = (end_index - limit.to_i)
    array_data[start_index..(end_index - 1)]
  end

  def valid_path_structure(path, dir_name)
    directory = File.join(path, dir_name)
    File.directory?(directory)
  end

end
