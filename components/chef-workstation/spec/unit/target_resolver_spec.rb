require "spec_helper"
require "chef-workstation/target_resolver"

RSpec.describe ChefWorkstation::TargetResolver do
  let(:target_string) { "" }
  subject { ChefWorkstation::TargetResolver.new(target_string, {}) }

  context "#targets" do
    context "when no target is provided" do
      let(:target_string) { "" }
      it "returns an empty array" do
        expect(subject.targets).to eq []
      end
    end

    context "when a single target is provided" do
      let(:target_string) { "ssh://localhost" }
      it "returns any array with one target" do
        actual_targets = subject.targets
        expect(actual_targets[0].config[:host]).to eq "localhost"
      end
    end

    context "when a comma-separated list of targets is provided" do
      let(:target_string) { "ssh://node1.example.com,winrm://node2.example.com" }
      it "returns an array with correct TargetHost instances" do
        actual_targets = subject.targets
        expect(actual_targets[0].config[:host]).to eq "node1.example.com"
        expect(actual_targets[1].config[:host]).to eq "node2.example.com"
      end
    end
    context "when a comma-separated list of targets that include ranges is provided" do
      let(:target_string) { "ssh://node[0:1],ssh://machine[0:1]" }
      it "returns an array with correct TargetHost instances" do
        actual_targets = subject.targets

        expect(actual_targets[0].config[:host]).to eq "node0"
        expect(actual_targets[1].config[:host]).to eq "node1"
        expect(actual_targets[2].config[:host]).to eq "machine0"
        expect(actual_targets[3].config[:host]).to eq "machine1"
      end
    end
  end

  context "#expand_targets" do
    it "returns a single item when no expansion is required" do
      expect(subject.expand_targets("one")).to eq ["one"]
    end

    it "expands single alphabetic range" do
      expect(subject.expand_targets("host[a:h]")).to eq %w{
        hosta hostb hostc hostd hoste hostf hostg hosth
      }
    end
    it "expands single alphabetic range even if reverse ordering is given" do
      expect(subject.expand_targets("host[h:a]")).to eq %w{
        hosta hostb hostc hostd hoste hostf hostg hosth
      }
    end

    it "expands a range when the target name is qualified with credentials" do
      expect(subject.expand_targets("ssh://user:password@host[a:b]")).to eq %w{
        ssh://user:password@hosta
        ssh://user:password@hostb
      }
    end

    it "expands single numeric range" do
      expect(subject.expand_targets("host[10:20]")).to eq %w{
        host10 host11 host12 host13 host14 host15 host16
        host17 host18 host19 host20
      }
    end

    it "expands two included ranges" do
      expect(subject.expand_targets("host[1:4].domain[a:c]")).to eq [
        "host1.domaina", "host1.domainb", "host1.domainc",
        "host2.domaina", "host2.domainb", "host2.domainc",
        "host3.domaina", "host3.domainb", "host3.domainc",
        "host4.domaina", "host4.domainb", "host4.domainc"
      ]
    end

    it "raises InvalidRange if a range mixes alpha and numeric" do
      expect { subject.expand_targets("host[a:9]") }.to raise_error(ChefWorkstation::TargetResolver::InvalidRange)
    end

    it "raises TooManyRanges if more than two ranges are included" do
      expect { subject.expand_targets("[0:1][5:10][10:11]") }.to raise_error(ChefWorkstation::TargetResolver::TooManyRanges)
    end

    context "when the target resolves to more than 24 names" do
      it "raises TooManyTargets if the target resolves to more than 25 names" do
        expect { subject.expand_targets("[0:99999]") }.to raise_error(ChefWorkstation::TargetResolver::TooManyTargets)
      end
    end
  end

end
