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
require "chef-run/target_resolver"

RSpec.describe ChefRun::TargetResolver do
  let(:target_string) { "" }
  let(:default_protocol) { "ssh" }
  let(:connection_options) { {} }
  subject { ChefRun::TargetResolver.new(target_string, default_protocol, connection_options) }

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

    context "when a mixed list of targets containing user prefix and not are included" do

      let(:target_string) { "test_user1@node1,node2,test_user2:password@node3" }

      context "and the :user option is provided" do

        let(:connection_options) { { user: "defaultuser" } }
        it "should default to the given :user only for the host that does not include name" do
          actual_targets = subject.targets
          tc = actual_targets[0].config
          expect(tc[:host]).to eq "node1"
          expect(tc[:user]).to eq "test_user1"

          tc = actual_targets[1].config
          expect(tc[:host]).to eq "node2"
          expect(tc[:user]).to eq "defaultuser"

          tc = actual_targets[2].config
          expect(tc[:host]).to eq "node3"
          expect(tc[:user]).to eq "test_user2"
        end
      end
      context "and the :user option is not provided" do
        let(:opts) { {} }
        it "should default to no user when user is not included with host" do
          actual_targets = subject.targets
          tc = actual_targets[0].config
          expect(tc[:host]).to eq "node1"
          expect(tc[:user]).to eq "test_user1"

          tc = actual_targets[1].config
          expect(tc[:host]).to eq "node2"
          expect(tc[:user]).to eq nil

          tc = actual_targets[2].config
          expect(tc[:host]).to eq "node3"
          expect(tc[:user]).to eq "test_user2"
        end
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

    it "expands a numeric range correctly when start/stop string values ASCII-sort in reverse" do
      # eg: ["4", "10"].sort => ["10", "4"]
      expect(subject.expand_targets("[4:10]")).to eq %w{ 4 5 6 7 8 9 10 }
    end

    it "expands a numeric range correctly when stop is higher than start" do
      expect(subject.expand_targets("[10:8]")).to eq %w{ 8 9 10 }
    end

    it "expands a string range correctly when stop is higher than start" do
      expect(subject.expand_targets("[z:y]")).to eq %w{ y z }
    end

    it "expands single numeric range" do
      expect(subject.expand_targets("host[10:20]")).to eq %w{
        host10 host11 host12 host13 host14 host15 host16
        host17 host18 host19 host20
      }
    end

    it "expands two included ranges" do
      expect(subject.expand_targets("host[1:4].domain[a:c]").sort).to eq [
        "host1.domaina", "host1.domainb", "host1.domainc",
        "host2.domaina", "host2.domainb", "host2.domainc",
        "host3.domaina", "host3.domainb", "host3.domainc",
        "host4.domaina", "host4.domainb", "host4.domainc"
      ].sort
    end

    it "raises InvalidRange if a range mixes alpha and numeric" do
      expect { subject.expand_targets("host[a:9]") }.to raise_error(ChefRun::TargetResolver::InvalidRange)
    end

    it "raises TooManyRanges if more than two ranges are included" do
      expect { subject.expand_targets("[0:1][5:10][10:11]") }.to raise_error(ChefRun::TargetResolver::TooManyRanges)
    end

    context "when the target resolves to more than #{ChefRun::TargetResolver::MAX_EXPANDED_TARGETS} names" do
      it "raises TooManyTargets" do
        expect { subject.expand_targets("[0:99999]") }.to raise_error(ChefRun::TargetResolver::TooManyTargets)
      end
    end
  end

  context "#make_credentials" do
    let(:default_user) { nil }
    let(:default_password) { nil }

    let(:inline_user) { nil }
    let(:inline_password) { nil }

    subject do
      opts = {}
      opts[:user] = default_user unless default_user.nil?
      opts[:password] = default_password unless default_password.nil?
      resolver = ChefRun::TargetResolver.new("", default_protocol, opts)
      Proc.new { resolver.make_credentials(inline_user, inline_password) }
    end

    context "when no default user or password is given" do
      let(:default_user) { nil }
      let(:default_password) { nil }

      context "and only an inline user is provided" do
        let(:inline_user) { "aninlineuser" }
        let(:inline_password) { nil }
        it "returns the decorated inline user with nil password" do
          expect(subject.call).to eq [inline_user, nil]
        end
      end

      context "and only an inline password is provided" do
        let(:inline_user) { nil }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the decorated inline password" do
          expect(subject.call).to eq [nil, inline_password]
        end
      end

      context "and neither inline user nor inline password is given" do
        let(:inline_user) { nil }
        let(:inline_password) { nil }
        it "returns an empty string" do
          expect(subject.call).to eq [nil, nil]
        end
      end

      context "and both inline user and inline password are given" do
        let(:inline_user) { "adefaultuser" }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the decorated inline_user and inline password" do
          expect(subject.call).to eq [inline_user, inline_password]
        end
      end
    end

    context "when only a default user is given" do
      let(:default_user) { "defaultusername" }
      let(:default_password) { nil }

      context "and only an inline user is provided" do
        let(:inline_user) { "aninlineuser" }
        let(:inline_password) { nil }
        it "returns the inline user with no password" do
          expect(subject.call).to eq [inline_user, nil]
        end
      end

      context "and only an inline password is provided" do
        let(:inline_user) { nil }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the default user and inline password" do
          expect(subject.call).to eq [default_user, inline_password]
        end
      end

      context "and neither inline user nor inline password is given" do
        let(:inline_user) { nil }
        let(:inline_password) { nil }
        it "returns the default user" do
          expect(subject.call).to eq [default_user, nil]
        end
      end

      context "and both inline user and inline password are given" do
        let(:inline_user) { "adefaultuser" }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the decorated inline_user and inline password" do
          expect(subject.call).to eq [inline_user, inline_password]
        end
      end
    end

    context "when only a default password is given" do
      let(:default_user) { nil }
      let(:default_password) { "ihasdefaultpassword" }

      context "and only an inline user is provided" do
        let(:inline_user) { "aninlineuser" }
        let(:inline_password) { nil }
        it "returns the decorated inline user and default password" do
          expect(subject.call).to eq [inline_user, default_password]
        end
      end

      context "and only an inline password is provided" do
        let(:inline_user) { nil }
        let(:inline_password) { "inlinepassword4u" }
        it "returns nil user and inline password" do
          expect(subject.call).to eq [nil, inline_password]
        end
      end

      context "and neither inline user nor inline password is given" do
        let(:inline_user) { nil }
        let(:inline_password) { nil }
        it "returns the nil user and default password" do
          expect(subject.call).to eq [nil, default_password]
        end
      end

      context "and both inline user and inline password are given" do
        let(:inline_user) { "adefaultuser" }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the inline_user and inline password" do
          expect(subject.call).to eq [inline_user, inline_password]
        end
      end
    end

    context "when defaults for both user and password are given" do
      let(:default_user) { "adefaultuser" }
      let(:default_password) { "ihasdefaultpassword" }

      context "and only an inline user is provided" do
        let(:inline_user) { "aninlineuser" }
        let(:inline_password) { nil }
        it "returns the decorated inline user and default password" do
          expect(subject.call).to eq [inline_user, default_password]
        end
      end

      context "and only an inline password is provided" do
        let(:inline_user) { nil }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the decorated default user and inline password" do
          expect(subject.call).to eq [default_user, inline_password]
        end
      end

      context "and neither inline user nor inline password is given" do
        let(:inline_user) { nil }
        let(:inline_password) { nil }
        it "returns the decorated default user and default password" do
          expect(subject.call).to eq [default_user, default_password]
        end
      end

      context "and both inline user and inline password are given" do
        let(:inline_user) { "adefaultuser" }
        let(:inline_password) { "inlinepassword4u" }
        it "returns the decorated inline_user and inline password" do
          expect(subject.call).to eq [inline_user, inline_password]
        end
      end
    end
  end

  context "#config_for_target" do
    { "example.com" => { password: nil, url: "ssh://example.com", user: nil },
      "ssh://example.com" =>  { password: nil, url: "ssh://example.com", user: nil },
      "ssh://user@example.com" => { password: nil, url: "ssh://example.com", user: "user" },
      "ssh://user:password@example.com" => { password: "password", user: "user", url: "ssh://example.com" },
      "ssh://user:pas:sw:ord@example.com" => { password: "pas:sw:ord", user: "user", url: "ssh://example.com" },
      "ssh://user:!@#$%^&*()|\'\";:/?><.,{}[]+=`~@example.com" => { password: "!@#$%^&*()|\'\";:/?><.,{}[]+=`~", user: "user", url: "ssh://example.com" }
    }.each do |values|
      it "resolves #{values[0]} to #{values[1]}" do
        expect(subject.config_for_target(values[0])).to eq values[1]
      end
    end

    it "preserves range specifiers in the host portion while encoding in the password portion" do
      input = "user:pas[1:2]!^@ho[a:b]s[t:z].com"
      output = { password: "pas[1:2]!^", url: "ssh://ho[a:b]s[t:z].com", user: "user" }
      expect(subject.config_for_target(input)).to eq output
    end
  end

  context "#prefix_from_target" do
    context "when no protocol is provided" do
      let(:default_protocol) { "badproto" }
      it "uses the default from configuration" do
        expect(subject.prefix_from_target("host.com")).to eq %w{badproto:// host.com}
      end
    end

    context "when protocol is provided" do
      context "and it is valid" do
        it "keeps the protocol" do
          expect(subject.prefix_from_target("ssh://host.com")).to eq %w{ssh:// host.com}
        end
      end
      context "and it is not valid" do
        it "raises an error" do
          expect { subject.prefix_from_target("bad://host.com") }.
            to raise_error(ChefRun::TargetResolver::UnsupportedProtocol)
        end
      end
    end
  end

end
