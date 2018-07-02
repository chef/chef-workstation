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
require "chef-run/ui/terminal"

RSpec.describe ChefRun::UI::Terminal do
  Terminal = ChefRun::UI::Terminal
  # Lets send our Terminal output somewhere so it does not clutter the
  # test output
  Terminal.location = StringIO.new

  it "correctly outputs a message" do
    expect { Terminal.output("test") }
      .to output("test\n").to_terminal
  end

  context "#render_job" do
    it "executes the provided block" do
      @ran = false
      Terminal.render_job("a message") { |reporter| @ran = true }
      expect(@ran).to eq true
    end
  end

  context "#render_parallel_jobs" do
    it "executes the provided job instances" do
      @job1ran = false
      @job2ran = false
      job1 = Terminal::Job.new("prefix", nil) do
        @job1ran = true
      end
      job2 = Terminal::Job.new("prefix", nil) do
        @job2ran = true
      end
      Terminal.render_parallel_jobs("a message", [job1, job2])
      expect(@job1ran).to eq true
      expect(@job2ran).to eq true
    end
  end

  describe ChefRun::UI::Terminal::Job do
    subject { ChefRun::UI::Terminal::Job }
    context "#exception" do
      context "when no exception occurs in execution" do
        context "and it's been invoked directly" do
          it "exception is nil" do
            job = subject.new("", nil) { 0 }
            job.run(ChefRun::MockReporter.new)
            expect(job.exception).to eq nil
          end
        end
        context "and it's running in a thread alongside other jobs" do
          it "exception is nil for each job" do
            job1 = subject.new("", nil) { 0 }
            job2 = subject.new("", nil) { 0 }
            threads = []
            threads << Thread.new { job1.run(ChefRun::MockReporter.new) }
            threads << Thread.new { job2.run(ChefRun::MockReporter.new) }
            threads.each(&:join)
            expect(job1.exception).to eq nil
            expect(job2.exception).to eq nil

          end
        end
      end
      context "when an exception occurs in execution" do
        context "and it's been invoked directly" do
          it "captures the exception in #exception" do
            expected_exception = StandardError.new("exception 1")
            job = subject.new("", nil) { |arg| raise expected_exception }
            job.run(ChefRun::MockReporter.new)
            expect(job.exception).to eq expected_exception
          end
        end

        context "and it's running in a thread alongside other jobs" do
          it "each job holds its own exception" do
            e1 = StandardError.new("exception 1")
            e2 = StandardError.new("exception 2")

            job1 = subject.new("", nil) { |_| raise e1 }
            job2 = subject.new("", nil) { |_| raise e2 }
            threads = []
            threads << Thread.new { job1.run(ChefRun::MockReporter.new) }
            threads << Thread.new { job2.run(ChefRun::MockReporter.new) }
            threads.each(&:join)
            expect(job1.exception).to eq e1
            expect(job2.exception).to eq e2
          end
        end
      end
    end
  end
end
