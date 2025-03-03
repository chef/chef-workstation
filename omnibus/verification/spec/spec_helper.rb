#
# Copyright:: Copyright (c) 2014-2018 Chef Software Inc.
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

require "rubygems"
require "rspec/mocks"

# needed since we stub it for every test
require "chef/workstation_config_loader"
require "chef/config"

require "chef-cli/cli"

require "simplecov"
SimpleCov.start

RSpec.configure do |c|
  c.include ChefCLI

  # Avoid loading config.rb/knife.rb unintentionally
  c.before(:each) do
    Chef::Config.reset
    Chef::Config.treat_deprecation_warnings_as_errors(true)
    allow_any_instance_of(Chef::WorkstationConfigLoader).to receive(:load)
  end

  c.after(:all) { clear_tempdir }

  c.filter_run focus: true
  c.run_all_when_everything_filtered = true

  c.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

end

# Helpers referenced in verification specs
def fixtures_path
  File.expand_path(File.dirname(__FILE__) + "/unit/fixtures/")
end

def reset_tempdir
  clear_tempdir
  FileUtils.mkdir_p(tempdir)
end

def clear_tempdir
  FileUtils.rm_rf(tempdir)
  @tmpdir = nil
end

def tempdir
  @tmpdir ||= Dir.mktmpdir("chef-cli")
  File.realpath(@tmpdir)
end
