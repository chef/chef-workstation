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
require "chef-run/log"
require "chef-run/error"

module ChefRun
  # This class knows how to create a local cookbook in a temp file, populate
  # it with various recipes, attributes, config, etc. and delete it when the
  # cookbook is no longer necessary
  class TempCookbook
    attr_reader :path

    # We expect name to come in as a list of strings - resource/resource_name
    # or cookbook/recipe combination
    def initialize
      @path = Dir.mktmpdir("cw")
    end

    def from_existing_recipe(existing_recipe_path)
      ext_name = File.extname(existing_recipe_path)
      raise UnsupportedExtension.new(ext_name) unless ext_name == ".rb"
      cb = cookbook_for_recipe(existing_recipe_path)
      if cb
        # Full existing cookbook - only needs policyfile
        ChefRun::Log.debug("Found full cookbook at path '#{cb[:path]}' and using recipe '#{cb[:recipe_name]}'")
        name = cb[:name]
        recipe_name = cb[:recipe_name]
        FileUtils.cp_r(cb[:path], path)
        # cp_r copies the whole existing cookbook into the tempdir so need to reset our path
        @path = File.join(path, File.basename(cb[:path]))
        generate_policyfile(name, recipe_name)
      else
        # Cookbook from single recipe not in a cookbook. We create the full cookbook
        # structure including metadata, then generate policyfile. We set the cookbook
        # name to the recipe name so hopefully this gives us better reporting info
        # in the future
        ChefRun::Log.debug("Found single recipe at path '#{existing_recipe_path}'")
        recipe = File.basename(existing_recipe_path)
        recipe_name = File.basename(existing_recipe_path, ext_name)
        name = "cw_recipe"
        recipes_dir = generate_recipes_dir
        # This has the potential to break if they specify a recipe without a .rb
        # extension, but lets wait to deal with that bug until we encounter it
        FileUtils.cp(existing_recipe_path, File.join(recipes_dir, recipe))
        generate_metadata(name)
        generate_policyfile(name, recipe_name)
      end
    end

    def from_resource(resource_type, resource_name, properties)
      # Generate a cookbook containing a single default recipe with the specified
      # resource in it. Incloud the resource type in the cookbook name so hopefully
      # this gives us better reporting info in the future.
      ChefRun::Log.debug("Generating cookbook for single resource '#{resource_type}[#{resource_name}]'")
      name = "cw_#{resource_type}"
      recipe_name = "default"
      recipes_dir = generate_recipes_dir
      File.open(File.join(recipes_dir, "#{recipe_name}.rb"), "w+") do |f|
        f.print(create_resource(resource_type, resource_name, properties))
      end
      generate_metadata(name)
      generate_policyfile(name, recipe_name)
    end

    def delete
      FileUtils.remove_entry path
    end

    def cookbook_for_recipe(existing_recipe_path)
      metadata = File.expand_path(File.join(existing_recipe_path, "../../metadata.rb"))
      if File.file?(metadata)
        require "chef/cookbook/metadata"
        m = Chef::Cookbook::Metadata.new
        m.from_file(metadata)
        {
          name: m.name,
          recipe_name: File.basename(existing_recipe_path, File.extname(existing_recipe_path)),
          path: File.expand_path(File.join(metadata, "../"))
        }
      else
        nil
      end
    end

    def generate_recipes_dir
      recipes_path = File.join(path, "recipes")
      FileUtils.mkdir_p(recipes_path)
      recipes_path
    end

    def generate_metadata(name)
      metadata_file = File.join(path, "metadata.rb")
      File.open(metadata_file, "w+") do |f|
        f.print("name \"#{name}\"\n")
      end
      metadata_file
    end

    def generate_policyfile(name, recipe_name)
      policy_file = File.join(path, "Policyfile.rb")
      if File.exist?(policy_file)
        File.open(policy_file, "a") do |f|
          # We override the specified run_list with the run_list we want.
          # We append and put this at the end of the file so it overrides
          # any specified run_list.
          f.print("\n# Overriding run_list with command line specified value\n")
          f.print("run_list \"#{name}::#{recipe_name}\"\n")
        end
      else
        File.open(policy_file, "w+") do |f|
          f.print("name \"#{name}_policy\"\n")
          ChefRun::Config.chef.cookbook_repo_paths.each do |p|
            f.print("default_source :chef_repo, \"#{p}\"\n")
          end
          f.print("default_source :supermarket\n")
          f.print("run_list \"#{name}::#{recipe_name}\"\n")
          f.print("cookbook \"#{name}\", path: \".\"\n")
        end
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

    class UnsupportedExtension < ChefRun::ErrorNoLogs
      def initialize(ext); super("CHEFVAL009", ext); end
    end
  end
end
