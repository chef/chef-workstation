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

require "spec_helper"
require "chef-run/recipe_lookup"
require "chef/exceptions"
require "chef/cookbook/cookbook_version_loader"
require "chef/cookbook_version"
require "chef/cookbook_loader"

RSpec.describe ChefRun::RecipeLookup do
  let(:repo_path) { "repo_path" }
  subject(:rp) { ChefRun::RecipeLookup.new([repo_path]) }
  VL = Chef::Cookbook::CookbookVersionLoader
  let(:version_loader) { instance_double(VL) }
  let(:cookbook_version) { instance_double(Chef::CookbookVersion, root_dir: "dir", name: "name") }
  let(:cookbook_loader) { instance_double(Chef::CookbookLoader, load_cookbooks_without_shadow_warning: nil) }

  describe "#split" do
    it "splits a customer provided specifier into a cookbook part and possible recipe part" do
      expect(rp.split("/some/path")).to eq(%w{/some/path})
      expect(rp.split("cookbook::recipe")).to eq(%w{cookbook recipe})
    end
  end

  describe "#load_cookbook" do
    context "when a directory is provided" do
      let(:recipe_specifier) { "/some/directory" }
      let(:default_recipe) { File.join(recipe_specifier, "default.rb") }
      let(:recipes_by_name) { { "default" => default_recipe } }
      before do
        expect(File).to receive(:directory?).with(recipe_specifier).and_return(true)
        expect(VL).to receive(:new).with(recipe_specifier).and_return(version_loader)
      end

      it "loads the cookbook and returns the path to the default recipe" do
        expect(version_loader).to receive(:load!)
        expect(version_loader).to receive(:cookbook_version).and_return(cookbook_version)
        expect(rp.load_cookbook(recipe_specifier)).to eq(cookbook_version)
      end

      context "the directory is not a cookbook" do
        it "raise an InvalidCookbook error" do
          expect(version_loader).to receive(:load!).and_raise(Chef::Exceptions::CookbookNotFoundInRepo.new)
          expect { rp.load_cookbook(recipe_specifier) }.to raise_error(ChefRun::RecipeLookup::InvalidCookbook)
        end
      end
    end

    context "when a cookbook name is provided" do
      let(:recipe_specifier) { "cb" }
      before do
        expect(File).to receive(:directory?).with(recipe_specifier).and_return(false)
        expect(Chef::CookbookLoader).to receive(:new).and_return(cookbook_loader)
      end

      context "and a cookbook in the cookbook repository exists with that name" do
        it "returns the default cookbook" do
          expect(cookbook_loader).to receive(:[]).with(recipe_specifier).and_return(cookbook_version)
          expect(rp.load_cookbook(recipe_specifier)).to eq(cookbook_version)
        end
      end

      context "and a cookbook exists but it is invalid" do
        it "raises an InvalidCookbook error" do
          expect(cookbook_loader).to receive(:[]).with(recipe_specifier).and_raise(Chef::Exceptions::CookbookNotFoundInRepo.new())
          expect(File).to receive(:directory?).with(File.join(repo_path, recipe_specifier)).and_return(true)
          expect { rp.load_cookbook(recipe_specifier) }.to raise_error(ChefRun::RecipeLookup::InvalidCookbook)
        end
      end

      context "and a cookbook does not exist" do
        it "raises an CookbookNotFound error" do
          expect(cookbook_loader).to receive(:[]).with(recipe_specifier).and_raise(Chef::Exceptions::CookbookNotFoundInRepo.new())
          expect(File).to receive(:directory?).with(File.join(repo_path, recipe_specifier)).and_return(false)
          expect { rp.load_cookbook(recipe_specifier) }.to raise_error(ChefRun::RecipeLookup::CookbookNotFound)
        end
      end
    end
  end

  describe "#find_recipe" do
    let(:recipe) { double("recipe") }

    context "no recipe is specified" do
      it "finds a default recipe" do
        expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return({ "default" => recipe })
        expect(rp.find_recipe(cookbook_version)).to eq(recipe)
      end
      it "when there is no default recipe it raises a NoDefaultRecipe error" do
        expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return({})
        expect { rp.find_recipe(cookbook_version) }.to raise_error(ChefRun::RecipeLookup::NoDefaultRecipe)
      end
    end

    context "a recipe is specified" do
      let(:desired_recipe) { "a_recipe" }
      it "finds the specified recipe" do
        expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return({ desired_recipe => recipe })
        expect(rp.find_recipe(cookbook_version, desired_recipe)).to eq(recipe)
      end
      it "when there is no recipe with that name it raises a RecipeNotFound error" do
        expect(cookbook_version).to receive(:recipe_filenames_by_name).and_return({})
        expect { rp.find_recipe(cookbook_version, desired_recipe) }.to raise_error(ChefRun::RecipeLookup::RecipeNotFound)
      end
    end
  end
end
