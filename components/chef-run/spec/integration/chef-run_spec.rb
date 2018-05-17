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
require "integration/spec_helper"
require "chef-run/cli"
require "chef-run/version"

RSpec.describe "chef-run" do
  context "help output" do
    context "at the top level" do
      ["-h", "--help", ""].each do |arg|
        it "#{arg} displays correct help" do
          expect { run_cli_with(arg) }.to output(fixture_content("chef_help")).to_stdout
        end
      end
    end
  end

  context "version output" do
    ["-v", "--version"].each do |arg|
      it "#{arg} displays correct version" do
        expect { run_cli_with(arg) }.to output(fixture_content("chef_version")).to_stdout
      end
    end
  end
end
