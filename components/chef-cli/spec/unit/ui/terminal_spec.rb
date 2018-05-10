require "chef-cli/ui/terminal"
require "spec_helper"

RSpec.describe ChefCLI::UI::Terminal do
  Terminal = ChefCLI::UI::Terminal
  let(:capture) { StringIO.new }

  # We must set the terminal location to $stdout because
  # of how RSpec works - trying to set it in a before block
  # won't capture the output
  # https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/output-matcher

  after do
    Terminal.init(File.open("/dev/null", "w"))
  end

  it "correctly outputs a message" do
    expect do
      Terminal.output("test")
    end.to output("test\n").to_terminal
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

  describe ChefCLI::UI::Terminal::Job do
    subject { ChefCLI::UI::Terminal::Job }
    context "#exception" do
      context "when no exception occurs in execution" do
        context "and it's been invoked directly" do
          it "exception is nil" do
            job = subject.new("", nil) { 0 }
            job.run(ChefCLI::MockReporter.new)
            expect(job.exception).to eq nil
          end
        end
        context "and it's running in a thread alongside other jobs" do
          it "exception is nil for each job" do
            job1 = subject.new("", nil) { 0 }
            job2 = subject.new("", nil) { 0 }
            threads = []
            threads << Thread.new { job1.run(ChefCLI::MockReporter.new) }
            threads << Thread.new { job2.run(ChefCLI::MockReporter.new) }
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
            job.run(ChefCLI::MockReporter.new)
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
            threads << Thread.new { job1.run(ChefCLI::MockReporter.new) }
            threads << Thread.new { job2.run(ChefCLI::MockReporter.new) }
            threads.each(&:join)
            expect(job1.exception).to eq e1
            expect(job2.exception).to eq e2
          end
        end
      end
    end
  end
end
