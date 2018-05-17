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

require "chef-run/file_fetcher"
require "spec_helper"

RSpec.describe ChefRun::FileFetcher do
  let(:expected_local_location) { File.join(ChefRun::Config.cache.path, "example.txt") }
  subject { ChefRun::FileFetcher }
  describe ".fetch" do
    it "returns the local path when the file is cached" do
      allow(FileUtils).to receive(:mkdir)
      expect(File).to receive(:exist?).with(expected_local_location).and_return(true)
      result = subject.fetch("https://example.com/example.txt")
      expect(result).to eq expected_local_location
    end

    it "returns the local path when the file is fetched" do
      allow(FileUtils).to receive(:mkdir)
      expect(File).to receive(:exist?).with(expected_local_location).and_return(false)
      expect(subject).to receive(:download_file)
      result = subject.fetch("https://example.com/example.txt")
      expect(result).to eq expected_local_location
    end
  end
end
