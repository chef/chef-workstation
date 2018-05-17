#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
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

require "chef-config/config"
require "chef-run/config"
require "chef-run/error"
require "chef-run/log"

module ChefRun
  # When users are trying to converge a local recipe on a remote target, there
  # is a very specific (but expansive) set of things they can specify. This
  # class encapsulates that logic for testing purposes. We either return
  # a path to a recipe or we raise an error.
  class RecipeLookup

    attr_reader :cookbook_repo_paths
    def initialize(cookbook_repo_paths)
      @cookbook_repo_paths = cookbook_repo_paths
    end

    # The recipe specifier is provided by the customer as either a path OR
    # a cookbook and optional recipe name.
    def split(recipe_specifier)
      recipe_specifier.split("::")
    end

    # Given a cookbook path or name, try to load that cookbook. Either return
    # a cookbook object or raise an error.
    def load_cookbook(path_or_name)
      require "chef/exceptions"
      if File.directory?(path_or_name)
        cookbook_path = path_or_name
        # First, is there a cookbook in the specified dir that matches?
        require "chef/cookbook/cookbook_version_loader"
        begin
          v = Chef::Cookbook::CookbookVersionLoader.new(cookbook_path)
          v.load!
          cookbook = v.cookbook_version
        rescue Chef::Exceptions::CookbookNotFoundInRepo
          raise InvalidCookbook.new(cookbook_path)
        end
      else
        cookbook_name = path_or_name
        # Second, is there a cookbook in their local repository that matches?
        require "chef/cookbook_loader"
        cb_loader = Chef::CookbookLoader.new(cookbook_repo_paths)
        cb_loader.load_cookbooks_without_shadow_warning

        begin
          cookbook = cb_loader[cookbook_name]
        rescue Chef::Exceptions::CookbookNotFoundInRepo
          cookbook_repo_paths.each do |repo_path|
            cookbook_path = File.join(repo_path, cookbook_name)
            if File.directory?(cookbook_path)
              raise InvalidCookbook.new(cookbook_path)
            end
          end
          raise CookbookNotFound.new(cookbook_name, cookbook_repo_paths)
        end
      end
      cookbook
    end

    # Find the specified recipe or default recipe if none is specified.
    # Raise an error if recipe cannot be found.
    def find_recipe(cookbook, recipe_name = nil)
      recipes = cookbook.recipe_filenames_by_name
      if recipe_name.nil?
        default_recipe = recipes["default"]
        raise NoDefaultRecipe.new(cookbook.root_dir, cookbook.name) if default_recipe.nil?
        default_recipe
      else
        recipe = recipes[recipe_name]
        raise RecipeNotFound.new(cookbook.root_dir, recipe_name, recipes.keys, cookbook.name) if recipe.nil?
        recipe
      end
    end

    class InvalidCookbook < ChefRun::Error
      def initialize(cookbook_path); super("CHEFVAL005", cookbook_path); end
    end

    class CookbookNotFound < ChefRun::Error
      def initialize(cookbook_name, repo_paths)
        repo_paths = repo_paths.join("\n")
        super("CHEFVAL006", cookbook_name, repo_paths)
      end
    end

    class NoDefaultRecipe < ChefRun::Error
      def initialize(cookbook_path, cookbook_name); super("CHEFVAL007", cookbook_path, cookbook_name); end
    end

    class RecipeNotFound < ChefRun::Error
      def initialize(cookbook_path, recipe_name, available_recipes, cookbook_name)
        available_recipes.map! { |r| "'#{r}'" }
        available_recipes = available_recipes.join(", ")
        super("CHEFVAL008", cookbook_path, recipe_name, available_recipes, cookbook_name)
      end
    end

  end
end
