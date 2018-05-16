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
  let(:existing_recipe) do
    t = Tempfile.new
    t.write(uuid)
    t.close
    t
  end

  after do
    tc.delete
    existing_recipe.unlink
  end

  describe "#from_existing_recipe" do
    it "copies the existing recipe" do
      tc.from_existing_recipe(existing_recipe.path)
      expect(File.read(File.join(tc.path, "recipes/default.rb"))).to eq(uuid)
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
      f = tc.generate_metadata
      expect(File.read(f)).to eq("name \"\"\n")
    end
  end

  describe "#generate_policyfile" do
    it "generates a policyfile in the temp cookbook" do
      f = tc.generate_policyfile
      expect(File.read(f)).to eq <<-EOD.gsub(/^ {6}/, "")
      name "_policy"
      default_source :supermarket
      run_list "::default"
      cookbook "", path: "."
      EOD
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
        expected = <<-EOH.gsub(/^\s{10}/, "")
          directory '/tmp' do
            key1 'value'
            key2 0.1
            key3 100
            key4 true
            key_with_underscore 'value'
          end
          EOH
        expect(tc.create_resource(r1, r2, props)).to eq(expected)
      end
    end
  end
end
