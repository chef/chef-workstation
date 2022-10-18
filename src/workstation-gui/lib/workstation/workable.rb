module Workstation
    module Workable
        DEFAULT_LIMIT = 10
        DEFAULT_PAGE = 1
        def chef_dir
            File.expand_path(File.join(Dir.home, ".chef")) # todo move this file in .chef string in module with constants
        end
    
        def chef_repo_storage_file
            File.expand_path(File.join(chef_dir, "repository.json"))
        end
    
        def create_chef_repo_storage_file
            File.open(chef_repo_storage_file, "w") do |f|
                f.write({ "repositories" => [] }.to_json)
            end
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
    
        def validate_dir_path(dir_path)
            File.directory?(dir_path)
        end
    
        def validate_file_path(file_path)
            File.file?(file_path)
        end
    
        def result_post_pagination(array_data, limit, page, total_size)
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
    
    
        def get_policy_file(filepath)
            res = Dir.entries(filepath).select { |f| f == 'Policyfile.rb' }
            return res[0] if !res.empty?
        
            res = Dir.entries(filepath).select { |f| f.split(".").include?('rb') } # NOTE- todo- logic if policyfile is named something else
            res-= ['metadata.rb']
            res[0] # todo- Need to confirm and check logic
        end
    
        def  get_recipe_count(dirpath)
            directory = File.join(dirpath, 'recipes')
            if validate_dir_path(directory)
                Dir.entries(directory).select { |f| f.split(".").include?('rb') }.size
            else
                0
            end
        end

        def validate_repo_by_path(data_list,repo_path)
            data_list.any? {|h| h["filepath"] == repo_path}
        end

        def validate_repo_by_id(data_list,id)
            data_list.any? {|h| h["id"] == id}
        end
    
    end
end
  