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
require "chef-workstation/command/base"
require "chef-workstation/commands_map"

RSpec.describe ChefWorkstation::Command::Base do
  let(:cmd_spec) { instance_double(ChefWorkstation::CommandsMap::CommandSpec, name: "cmd", subcommands: []) }
  subject(:cmd) do
    allow(cmd_spec).to receive(:qualified_name).and_return "blah"
    ChefWorkstation::Command::Base.new(cmd_spec)
  end

  describe "run" do
    it "shows help" do
      expect(subject).to receive(:show_help)
      subject.run([])
    end
  end

  describe "run_with_default_options" do
    context "with no arguments" do
      it "invokes show_help" do
        expect(subject).to receive(:show_help)
        subject.run_with_default_options([])
      end
    end
    context "with help arguments" do
      %w{--help -h}.each do |arg|
        it "shows help when run with #{arg}" do
          expect(subject).to receive(:show_help)
          subject.run_with_default_options([arg])
        end
      end
    end
    context "with version arguments" do
      %w{--version -v}.each do |arg|
        it "shows version when run with #{arg}" do
          expect(subject).to receive(:show_version)
          subject.run_with_default_options([arg])
        end
      end
    end
  end
end
