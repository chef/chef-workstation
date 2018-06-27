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
require "chef-run/temp_cookbook"
require "tempfile"
require "securerandom"

RSpec.describe ChefRun::TempCookbook do
  subject(:tc) { ChefRun::TempCookbook.new }
  let(:uuid) { SecureRandom.uuid }

  before do
    @repo_paths = ChefRun::Config.chef.cookbook_repo_paths
    ChefRun::Config.chef.cookbook_repo_paths = []
  end

  after do
    ChefRun::Config.chef.cookbook_repo_paths = @repo_paths
    tc.delete
  end

  describe "#from_existing_recipe" do
    it "raises an error if the recipe does not have a .rb extension" do
      err = ChefRun::TempCookbook::UnsupportedExtension
      expect { tc.from_existing_recipe("/some/file.chef") }.to raise_error(err)
    end

    context "when there is an existing cookbook" do
      let(:cb) do
        d = Dir.mktmpdir
        File.open(File.join(d, "metadata.rb"), "w+") do |f|
          f << "name \"foo\""
        end
        FileUtils.mkdir(File.join(d, "recipes"))
        d
      end

      let(:existing_recipe) do
        File.open(File.join(cb, "recipes/default.rb"), "w+") do |f|
          f.write(uuid)
          f
        end
      end

      after do
        FileUtils.remove_entry cb
      end

      it "copies the whole cookbook" do
        tc.from_existing_recipe(existing_recipe.path)
        expect(File.read(File.join(tc.path, "recipes/default.rb"))).to eq(uuid)
        expect(File.read(File.join(tc.path, "Policyfile.rb"))).to eq <<~EXPECTED_POLICYFILE
          name "foo_policy"
          default_source :supermarket
          run_list "foo::default"
          cookbook "foo", path: "."
        EXPECTED_POLICYFILE
        expect(File.read(File.join(tc.path, "metadata.rb"))).to eq("name \"foo\"")
      end
    end

    context "when there is only a single recipe not in a cookbook" do
      let(:existing_recipe) do
        t = Tempfile.new(["recipe", ".rb"])
        t.write(uuid)
        t.close
        t
      end

      after do
        existing_recipe.unlink
      end

      it "copies the existing recipe into a new cookbook" do
        tc.from_existing_recipe(existing_recipe.path)
        recipe_filename = File.basename(existing_recipe.path)
        recipe_name = File.basename(recipe_filename, File.extname(recipe_filename))
        expect(File.read(File.join(tc.path, "recipes/", recipe_filename))).to eq(uuid)
        expect(File.read(File.join(tc.path, "Policyfile.rb"))).to eq <<~EXPECTED_POLICYFILE
          name "cw_recipe_policy"
          default_source :supermarket
          run_list "cw_recipe::#{recipe_name}"
          cookbook "cw_recipe", path: "."
        EXPECTED_POLICYFILE
        expect(File.read(File.join(tc.path, "metadata.rb"))).to eq("name \"cw_recipe\"\n")
      end
    end
  end

  describe "#from_resource" do
    it "creates a recipe containing the supplied recipe" do
      tc.from_resource("directory", "/tmp/foo", [])
      expect(File.read(File.join(tc.path, "recipes/default.rb"))).to eq("directory '/tmp/foo'\n")
    end
  end

  describe "#generate_metadata" do
    it "generates metadata in the temp cookbook" do
      f = tc.generate_metadata("foo")
      expect(File.read(f)).to eq("name \"foo\"\n")
    end
  end

  describe "#generate_policyfile" do
    context "when there is no existing policyfile" do
      it "generates a policyfile in the temp cookbook" do
        f = tc.generate_policyfile("foo", "bar")
        expect(File.read(f)).to eq <<~EXPECTED_POLICYFILE
          name "foo_policy"
          default_source :supermarket
          run_list "foo::bar"
          cookbook "foo", path: "."
        EXPECTED_POLICYFILE
      end

      context "when there are configured cookbook_repo_paths" do
        it "generates a policyfile in the temp cookbook" do
          ChefRun::Config.chef.cookbook_repo_paths = %w{one two}
          f = tc.generate_policyfile("foo", "bar")
          expect(File.read(f)).to eq <<~EXPECTED_POLICYFILE
            name "foo_policy"
            default_source :chef_repo, "one"
            default_source :chef_repo, "two"
            default_source :supermarket
            run_list "foo::bar"
            cookbook "foo", path: "."
          EXPECTED_POLICYFILE
        end
      end
    end

    context "when there is an existing policyfile" do
      before do
        File.open(File.join(tc.path, "Policyfile.rb"), "a") do |f|
          f << "this is a policyfile"
        end
      end
      it "only overrides the existing run_list in the policyfile" do
        f = tc.generate_policyfile("foo", "bar")
        expect(File.read(f)).to eq <<~EXPECTED_POLICYFILE
          this is a policyfile
          # Overriding run_list with command line specified value
          run_list "foo::bar"
        EXPECTED_POLICYFILE
      end
    end
  end

  describe "#create_resource" do
    let(:r1) { "directory" }
    let(:r2) { "/tmp" }
    let(:props) { nil }
    context "when no properties are provided" do
      it "it creates a simple resource" do
        expect(tc.create_resource(r1, r2, [])).to eq("directory '/tmp'\n")
      end
    end

    context "when properties are provided" do
      let(:props) do
        {
          "key1" => "value",
          "key2" => 0.1,
          "key3" => 100,
          "key4" => true,
          "key_with_underscore" => "value",
        }
      end

      it "converts the properties to chef-client args" do
        expected = <<~EXPECTED_RESOURCE
          directory '/tmp' do
            key1 'value'
            key2 0.1
            key3 100
            key4 true
            key_with_underscore 'value'
          end
        EXPECTED_RESOURCE
        expect(tc.create_resource(r1, r2, props)).to eq(expected)
      end
    end
  end
end
