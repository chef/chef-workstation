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
require "chef-run/cli"
require "chef-run/ui/terminal"

RSpec.describe ChefRun::CLI do
  let(:argv) { [] }

  subject(:cli) do
    ChefRun::CLI.new(argv)
  end

  context "run" do
    context "with no arguments" do
      it "exits successfully" do
        expect { subject.run }.to raise_error SystemExit
      end

      it "sets up the cli" do
        expect(subject).to receive(:setup_cli)
        expect { subject.run }.to raise_error SystemExit
      end
    end
  end

  context "#setup_cli" do
    it "initializes ChefRun::UI::Terminal" do
      expect(ChefRun::UI::Terminal).to receive(:init).with($stdout)
      subject.setup_cli
    end

    # TODO: JM 5/15/18 Add tests to ensure config is handled appropriately.
  end
end
