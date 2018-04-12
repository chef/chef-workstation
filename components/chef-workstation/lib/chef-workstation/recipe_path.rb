require "chef-workstation/config"
require "chef-workstation/error"
require "chef-workstation/log"

module ChefWorkstation
  class RecipePath

    # When users are trying to converge a local recipe on a remote target, there
    # is a very specific (but expansive) set of things they can specify. This
    # class encapsulates that logic for testing purposes. We either return
    # a path to a recipe or we raise an error.
    def self.resolve(path, chef_repo_path=nil)
      # First, we check to see if the user has specified the full path (absolute or relative)
      # to a file. If they have, we assume that is a recipe they want to execute.
      if File.file?(recipe_specifier)
        ChefWorkstation::Log.debug("#{recipe_specifier} is a valid path to a recipe")
        recipe_specifier
      # Second, we check to see if the user specified the full path (absolute or relative)
      # to a folder. If they have we assume that folder is a cookbook and we try to load
      # the default recipe from it, or if it is a single file cookbook load that recipe
      elsif File.directory?(recipe_specifier)
        cookbook_path = recipe_specifier
        ChefWorkstation::Log.debug("#{cookbook_path} looks like a folder that could be a cookbook")
        cookbook = load_cookbook(cookbook_path)
        all_files = cookbook[:all_files]
        get_default_recipe_from_cookbook_files(all_files)
      # Last, we assume they specified a 'cookbook' or 'cookbook::recipe' syntax. We
      # look for that cookbook in the chef_repo_path
      else
        ChefWorkstation::Log.debug("#{recipe_specifier} looks like a cookbook specifier")
        # This is a 'cookbook' or 'cookbook::recipe' specifier
        cookbook_name, recipe = recipe_specifier.split("::")

        if Dir.exist?(cookbook_name)
          # First, is there a cookbook in the specified dir that matches?
          cookbook = load_cookbook(cookbook_name)
        else
          # Second, is there a cookbook in their local repo that matches?
          require "chef-config/config"
          require "chef-config/workstation_config_loader"
          require "chef/cookbook_loader"
          repo_path = chef_repo_path || find_chef_repo_path
          cb_loader = Chef::CookbookLoader.new(repo_path)
          cb_loader.load_cookbooks_without_shadow_warning

          begin
            cookbook = cb_loader[cookbook]
          rescue Chef::Exceptions::CookbookNotFoundInRepo
            raise CookbookNotFound.new(cookbook, repo_path)
          end
        end
        all_files = cookbook[:all_files]
        if recipe.nil?
          get_default_recipe_from_cookbook_files(all_files)
        else
          recipe = all_files[Pathname.new("recipes/#{recipe}.rb")]
          raise RecipeNotFound.new(File.expand_path(cookbook_name)) if recipe.nil?
          recipe
        end
      end
    end

    def self.load_cookbook(cookbook_path)
      require "chef/exceptions"
      require "chef/cookbook/cookbook_version_loader"
      begin
        Chef::Cookbook::CookbookVersionLoader.new(cookbook_path).load!
      rescue Chef::Exceptions::CookbookNotFoundInRepo
        raise InvalidCookbook.new(File.expand_path(cookbook_path))
      end
    end

    def self.get_default_recipe_from_cookbook_files(all_files)
      default_recipe = all_files[Pathname.new("recipes/default.rb")]
      return default_recipe unless default_recipe.nil?

      # There was no default.rb recipe, look for single file cookbook pattern
      single_file = all_files[Pathname.new("recipe.rb")]
      raise NoDefaultRecipe.new(File.expand_path(cookbook_path)) if single_file.nil?
      single_file
    end

    def self.find_chef_repo_path
      ChefConfig::WorkstationConfigLoader.new(nil).load
      repo_path = ChefConfig::Config[:chef_repo_path]
    end

    class InvalidCookbook < ChefWorkstation::Error
      def initialize(cookbook_path); super("CHEFVAL005", cookbook_path); end
    end

    class CookbookNotFound < ChefWorkstation::Error
      def initialize(cookbook_name, repo_path); super("CHEFVAL006", cookbook_name, repo_path); end
    end

    class NoDefaultRecipe < ChefWorkstation::Error
      def initialize(cookbook_path); super("CHEFVAL007", cookbook_path); end
    end

    class RecipeNotFound < ChefWorkstation::Error
      def initialize(cookbook_path, recipe_name); super("CHEFVAL008", cookbook_path, recipe_name); end
    end
  end
end
