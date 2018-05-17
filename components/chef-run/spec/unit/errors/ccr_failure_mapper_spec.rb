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
require "chef-run/errors/ccr_failure_mapper"

RSpec.describe ChefRun::Errors::CCRFailureMapper do
  let(:cause_line) { nil }
  let(:resource) { "apt_package" }
  let(:params) do
    { resource: resource, resource_name: "a-test-thing",
      stderr: "an error", stdout: "other output" }
  end
  subject { ChefRun::Errors::CCRFailureMapper.new(cause_line, params) }

  describe "#exception_args_from_cause" do
    context "when resource properties have valid names but invalid values" do
      context "and the property is 'action'" do
        let(:cause_line) { "Chef::Exceptions::ValidationFailed: Option action must be equal to one of: nothing, install, upgrade, remove, purge, reconfig, lock, unlock!  You passed :marve." }
        it "returns a correct CHEFCCR003" do
          expect(subject.exception_args_from_cause).to eq(
            ["CHEFCCR003", "marve",
             "nothing, install, upgrade, remove, purge, reconfig, lock, unlock"]
          )
        end
      end

      context "and the property is something else" do
        context "and details are available" do
          let(:cause_line) { "Chef::Exceptions::ValidationFailed: Option force must be a kind of [TrueClass, FalseClass]!  You passed \"purle\"." }
          it "returns a correct CHEFCCR004 when details are available" do
            expect(subject.exception_args_from_cause).to eq(
              ["CHEFCCR004",
               "Option force must be a kind of [TrueClass, FalseClass]!  You passed \"purle\"."])
          end
        end
        context "And less detail is available" do
          let(:cause_line) { "Chef::Exceptions::User: linux_user[marc] ((chef-client cookbook)::(chef-client recipe) line 1) had an error: Chef::Exceptions::User: Couldn't lookup integer GID for group name blah" }
          it "returns a correct CHEFCCR002" do
            expect(subject.exception_args_from_cause).to eq(
              ["CHEFCCR002", "Couldn't lookup integer GID for group name blah"])
          end
        end
      end
    end

    context "when resource is not a known Chef resource" do
      let(:cause_line) { "NoMethodError: undefined method `useraaa' for cookbook: (chef-client cookbook), recipe: (chef-client recipe) :Chef::Recipe" }
      let(:resource) { "useraaa" }
      it "returns a correct CHEFCCR005" do
        expect(subject.exception_args_from_cause).to eq(["CHEFCCR005", resource])
      end
    end

    context "when a resource property does not exist for the given resource" do
      let(:cause_line) { "NoMethodError: undefined method `badresourceprop' for Chef::Resource::User::LinuxUser" }
      it "returns a correct CHEFCCR006 " do
        expect(subject.exception_args_from_cause).to eq(
          ["CHEFCCR006", "badresourceprop", "Chef::Resource::User::LinuxUser"])
      end
    end
  end

  describe "#raise_mapped_exception!" do
    context "when no cause is provided" do
      let(:cause_line) { nil }
      it "raises a RemoteChefRunFailedToResolveError" do
        expect { subject.raise_mapped_exception! }.to raise_error(ChefRun::Errors::CCRFailureMapper::RemoteChefRunFailedToResolveError)

      end
    end

    context "when a cause is provided" do
      context "but can't resolve it" do
        let(:cause_line) { "unparseable mess" }
        it "raises a RemoteChefClientRunFailedUnknownReason" do
          expect { subject.raise_mapped_exception! }.to raise_error(ChefRun::Errors::CCRFailureMapper::RemoteChefClientRunFailedUnknownReason)
        end
      end

      context "and can resolve the cause" do
        let(:cause_line) { "NoMethodError: undefined method `badresourceprop' for Chef::Resource::User::LinuxUser" }
        it "raises a RemoteChefClientRunFailed" do
          expect { subject.raise_mapped_exception! }.to raise_error(ChefRun::Errors::CCRFailureMapper::RemoteChefClientRunFailed)
        end
      end
    end
  end
end
