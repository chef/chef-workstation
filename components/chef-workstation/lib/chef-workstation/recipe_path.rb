require "chef-workstation/config"
require "chef-workstation/error"
require "chef-workstation/log"

module ChefWorkstation
  class RecipePath

    # When users are trying to converge a local recipe on a remote target, there
    # is a very specific (but expansive) set of things they can specify. This
    # class encapsulates that logic for testing purposes. We either return
    # a path to a recipe or we raise an error.
    def self.resolve(recipe_specifier, cookbook_repo_path=nil)
      # First, we check to see if the user has specified the full path (absolute or relative)
      # to a file. If they have, we assume that is a recipe they want to execute.
      if File.file?(recipe_specifier)
        ChefWorkstation::Log.debug("#{recipe_specifier} is a valid path to a recipe")
        recipe_specifier
      # Second, we check to see if the user specified the full path (absolute or relative)
      # to a folder. If they have we assume that folder is a cookbook and we try to load
      # the default recipe from it, or if it is a single file cookbook load that recipe
      elsif File.directory?(recipe_specifier)
        ChefWorkstation::Log.debug("#{recipe_specifier} looks like a folder that could be a cookbook")
        cookbook = load_cookbook(recipe_specifier)
        recipes = cookbook.recipe_filenames_by_name
        default_recipe = recipes["default"]
        raise NoDefaultRecipe.new(cookbook.root_dir, cookbook.name) if default_recipe.nil?
        default_recipe
      # Last, we assume they specified a 'cookbook' or 'cookbook::recipe' syntax. We
      # look for that cookbook in the cookbook_path
      else
        ChefWorkstation::Log.debug("#{recipe_specifier} looks like a cookbook specifier")
        # This is a 'cookbook' or 'cookbook::recipe' specifier
        cookbook_name, recipe_name = recipe_specifier.split("::")

        if Dir.exist?(cookbook_name)
          # First, is there a cookbook in the specified dir that matches?
          cookbook = load_cookbook(cookbook_name)
        else
          # Second, is there a cookbook in their local repo that matches?
          # TODO initialize Chef logger to send to our log
          require "chef-config/config"
          require "chef-config/workstation_config_loader"
          require "chef/cookbook_loader"
          cookbook_repo_path = cookbook_repo_path || chef_cookbook_path
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
    end

    def self.load_cookbook(cookbook_path)
      require "chef/exceptions"
      require "chef/cookbook/cookbook_version_loader"
      begin
        v = Chef::Cookbook::CookbookVersionLoader.new(cookbook_path)
        v.load!
        v.cookbook_version
      rescue Chef::Exceptions::CookbookNotFoundInRepo => e
        raise InvalidCookbook.new(File.expand_path(cookbook_path), e.message)
      end
    end

    def self.chef_cookbook_path
      ChefConfig::WorkstationConfigLoader.new(nil).load
      repo_path = ChefConfig::Config[:cookbook_path]
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
        available_recipes.map! { |r| "'#{r}'"}
        available_recipes = available_recipes.join(", ")
        super("CHEFVAL008", cookbook_path, recipe_name, available_recipes)
      end
    end
  end
end
