#
# Copyright:: Copyright (c) 2018 Chef Software Inc.
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
require "tmpdir"
require "fileutils"

module ChefWorkstation
  # This class knows how to create a local cookbook in a temp file, populate
  # it with various recipes, attributes, config, etc. and delete it when the
  # cookbook is no longer necessary
  class TempCookbook
    attr_reader :path

    # We expect name to come in as a list of strings - resource/resource_name
    # or cookbook/recipe combination
    def initialize
      @path = Dir.mktmpdir("cw")
      @recipe_name = "default"
      @recipe_path = File.join(generate_recipes_dir, "#{@recipe_name}.rb")
    end

    def from_existing_recipe(existing_recipe_path)
      @name = "cw_#{File.basename(path)}"

      FileUtils.cp(existing_recipe_path, @recipe_path)

      generate_metadata
      generate_policyfile
    end

    def from_resource(resource_type, resource_name, properties)
      @name = "cw_#{resource_type}"

      File.open(@recipe_path, "w+") do |f|
        f.print(create_resource(resource_type, resource_name, properties))
      end

      generate_metadata
      generate_policyfile
    end

    def delete
      FileUtils.remove_entry path
    end

    def generate_recipes_dir
      recipes_path = File.join(path, "recipes")
      FileUtils.mkdir_p(recipes_path)
      recipes_path
    end

    def generate_metadata
      metadata_file = File.join(path, "metadata.rb")
      File.open(metadata_file, "w+") do |f|
        f.print("name \"#{@name}\"\n")
      end
      metadata_file
    end

    def generate_policyfile
      policy_file = File.join(path, "Policyfile.rb")
      File.open(policy_file, "w+") do |f|
        f.print("name \"#{@name}_policy\"\n")
        f.print("default_source :supermarket\n")
        f.print("run_list \"#{@name}::#{@recipe_name}\"\n")
        f.print("cookbook \"#{@name}\", path: \".\"\n")
      end
      policy_file
    end

    def create_resource(resource_type, resource_name, properties)
      r = "#{resource_type} '#{resource_name}'"
      # lets format the properties into the correct syntax Chef expects
      unless properties.empty?
        r += " do\n"
        properties.each do |k, v|
          v = "'#{v}'" if v.is_a? String
          r += "  #{k} #{v}\n"
        end
        r += "end"
      end
      r += "\n"
      r
    end

  end
end
