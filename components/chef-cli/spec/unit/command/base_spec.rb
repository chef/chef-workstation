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
require "chef-cli/command/base"
require "chef-cli/commands_map"
require "chef-cli/error"

RSpec.describe ChefCLI::Command::Base do
  let(:cmd_spec) { instance_double(ChefCLI::CommandsMap::CommandSpec, name: "cmd", subcommands: []) }
  subject(:cmd) do
    allow(cmd_spec).to receive(:qualified_name).and_return "blah"
    ChefCLI::Command::Base.new(cmd_spec)
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
  end

  describe "#handle_job_failures" do
    let(:passing_job) { double("PassingJob", exception: nil) }
    let(:failing_job_1) { double("FailingJob1", exception: "failed 1") }
    let(:failing_job_2) { double("FailingJob2", exception: "failed 2") }

    context "when all jobs pass" do
      let(:jobs) { [ passing_job, passing_job] }
      it "returns without raising any exception" do
        subject.handle_job_failures(jobs)
      end
    end

    context "when at least one job fails" do
      let(:jobs) { [ failing_job_1, passing_job, failing_job_2 ] }
      it "raises a MulitJobFailure containing the failed jobs" do
        expect { subject.handle_job_failures(jobs) }.to raise_error(ChefCLI::MultiJobFailure) do |e|
          expect(e.jobs).to eq [failing_job_1, failing_job_2]
        end
      end
    end

  end

end
