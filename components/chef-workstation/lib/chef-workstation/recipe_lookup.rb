require "chef-workstation/config"
require "chef-workstation/error"
require "chef-workstation/log"

module ChefWorkstation
  # When users are trying to converge a local recipe on a remote target, there
  # is a very specific (but expansive) set of things they can specify. This
  # class encapsulates that logic for testing purposes. We either return
  # a path to a recipe or we raise an error.
  class RecipeLookup

    # The recipe specifier is provided by the customer as either a path OR
    # a cookbook and optional recipe name.
    def split(recipe_specifier)
      recipe_specifier.split("::")
    end

    # Given a cookbook path or name, try to load that cookbook. Either return
    # a cookbook object or raise an error.
    def load_cookbook(path_or_name)
      if File.directory?(path_or_name)
        cookbook_path = path_or_name
        # First, is there a cookbook in the specified dir that matches?
        require "chef/exceptions"
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
        # Second, is there a cookbook in their local repo that matches?
        # TODO initialize Chef logger to send to our log
        require "chef-config/config"
        require "chef-config/workstation_config_loader"
        require "chef/cookbook_loader"
        cookbook_repo_path ||= chef_cookbook_path
        cb_loader = Chef::CookbookLoader.new(cookbook_repo_path)
        cb_loader.load_cookbooks_without_shadow_warning

        begin
          cookbook = cb_loader[cookbook_name]
        rescue Chef::Exceptions::CookbookNotFoundInRepo
          cookbook_path = File.join(cookbook_repo_path, cookbook_name)
          if File.directory?(cookbook_path)
            raise InvalidCookbook.new(cookbook_path)
          end
          raise CookbookNotFound.new(cookbook_name, cookbook_repo_path)
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
        raise RecipeNotFound.new(cookbook.root_dir, recipe_name, recipes.keys) if recipe.nil?
        recipe
      end
    end

    def chef_cookbook_path
      ChefConfig::WorkstationConfigLoader.new(nil).load
      ChefConfig::Config[:cookbook_path]
    end

    class InvalidCookbook < ChefWorkstation::Error
      def initialize(cookbook_path); super("CHEFVAL005", cookbook_path); end
    end

    class CookbookNotFound < ChefWorkstation::Error
      def initialize(cookbook_name, repo_path); super("CHEFVAL006", cookbook_name, repo_path); end
    end

    class NoDefaultRecipe < ChefWorkstation::Error
      def initialize(cookbook_path, cookbook_name); super("CHEFVAL007", cookbook_path, cookbook_name); end
    end

    class RecipeNotFound < ChefWorkstation::Error
      def initialize(cookbook_path, recipe_name, available_recipes)
        available_recipes.map! { |r| "'#{r}'" }
        available_recipes = available_recipes.join(", ")
        super("CHEFVAL008", cookbook_path, recipe_name, available_recipes)
      end
    end

  end
end
