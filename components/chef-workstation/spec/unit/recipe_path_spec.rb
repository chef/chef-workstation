require "spec_helper"
require "chef-workstation/recipe_path"
require "chef/exceptions"
require "chef/cookbook/cookbook_version_loader"
require "chef/cookbook_version"

RSpec.describe ChefWorkstation::RecipePath do
  RP = ChefWorkstation::RecipePath
  VL = Chef::Cookbook::CookbookVersionLoader
  let(:version_loader) { instance_double(VL) }
  let(:cookbook_version) { instance_double(Chef::CookbookVersion, root_dir: "dir", name: "name") }

  context "when a single file is provided" do
    let(:recipe_specifier) { "/some/file.rb" }
    it "returns the recipe_specifier" do
      expect(File).to receive(:file?).with(recipe_specifier).and_return(true)
      expect(RP.resolve(recipe_specifier)).to eq(recipe_specifier)
    end
  end

  context "when a directory is provided" do
    let(:recipe_specifier) { "/some/directory" }
    let(:default_recipe) { File.join(recipe_specifier, "default.rb") }
    let(:recipes_by_name) { {"default" => default_recipe} }
    before do
      expect(File).to receive(:directory?).with(recipe_specifier).and_return(true)
      expect(VL).to receive(:new).with(recipe_specifier).and_return(version_loader)
    end

    it "loads the cookbook and returns the path to the default recipe" do
      expect(version_loader).to receive(:load!)
      expect(version_loader).to receive(:cookbook_version).and_return(cookbook_version)
      expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return(recipes_by_name)
      expect(RP.resolve(recipe_specifier)).to eq(default_recipe)
    end

    context "the directory is not a cookbook" do
      it "raise an InvalidCookbook error" do
        expect(version_loader).to receive(:load!).and_raise(Chef::Exceptions::CookbookNotFoundInRepo.new)
        expect {RP.resolve(recipe_specifier) }.to raise_error(RP::InvalidCookbook)
      end
    end

    context "there is no default recipe" do
      it "raises an NoDefaultRecipe error" do
        expect(version_loader).to receive(:load!)
        expect(version_loader).to receive(:cookbook_version).and_return(cookbook_version)
        expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return({})
        expect {RP.resolve(recipe_specifier) }.to raise_error(RP::NoDefaultRecipe)
      end
    end
  end

  context "when a cookbook name is provided", pending: true do
    let(:recipe_specifier) { "cb" }
    let(:repo_path) { "repo_path" }
    context "and a cookbook in the cookbook repo exists with that name" do
      it "returns the default cookbook" do

      end
    end
  end

  context "when a cookbook name and recipe name are provided" do

  end
end
