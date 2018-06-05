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
require "chef-run/config"

RSpec.describe ChefRun::Config do
  subject(:config) do
    ChefRun::Config
  end

  before(:each) do
    ChefRun::Config.reset
  end

  it "raises an error when trying to specify non-existing config location" do
    expect { config.custom_location("/does/not/exist") }.to raise_error(RuntimeError, /No config file/)
  end

  it "should use default location by default" do
    expect(config.using_default_location?).to eq(true)
  end

  context "when there is a custom config" do
    let(:custom_config) { File.expand_path("../../fixtures/custom_config.toml", __FILE__) }

    it "successfully loads the config" do
      config.custom_location(custom_config)
      expect(config.using_default_location?).to eq(false)
      expect(config.exist?).to eq(true)
      config.load
      expect(config.telemetry.dev).to eq(true)
    end
  end
  describe "#load" do
    before do
      expect(subject).to receive(:exist?).and_return(exists)
    end

    context "when the config file exists" do
      let(:exists) { true }
      it "loads the file" do
        expect(subject).to receive(:from_file)
        subject.load
      end
    end

    context "when the config file does not exist" do
      let(:exists) { false }
      it "does not try to load the file" do
        expect(subject).to_not receive(:from_file)
        subject.load
      end
    end
  end
end
