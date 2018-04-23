require "chef-workstation/file_fetcher"
require "spec_helper"

RSpec.describe ChefWorkstation::FileFetcher do
  let(:expected_local_location) { File.join(ChefWorkstation::Config.cache.path, "example.txt") }
  subject { ChefWorkstation::FileFetcher }
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
