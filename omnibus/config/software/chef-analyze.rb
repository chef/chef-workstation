name "chef-analyze"
default_version "main"
license "Apache-2.0"
license_file "LICENSE"

# Dynamically fetch the latest commit hash for the main branch
latest_commit = `git ls-remote https://github.com/chef/chef-analyze.git refs/heads/main | awk '{print $1}'`.strip
raise "Failed to fetch the latest commit hash for chef-analyze" if latest_commit.empty?

# Dynamically calculate the SHA256 checksum of the tarball
tarball_url = "https://github.com/chef/chef-analyze/archive/#{latest_commit}.tar.gz"
tarball_path = "/tmp/chef-analyze-#{latest_commit}.tar.gz"

# Download the tarball
`curl -L -o #{tarball_path} #{tarball_url}`
raise "Failed to download tarball from #{tarball_url}" unless File.exist?(tarball_path)

# Calculate the SHA256 checksum
sha256 = `shasum -a 256 #{tarball_path} | awk '{print $1}'`.strip
raise "Failed to calculate SHA256 checksum for #{tarball_path}" if sha256.empty?

# Define the source block with the dynamically fetched version and checksum
source git: "https://github.com/chef/chef-analyze.git" do |s|
  s.version latest_commit
  s.sha256 sha256
end

# Update the internal_source URL to match the dynamically fetched version
internal_source url: tarball_url

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "1"
  file_extension = windows? ? ".exe" : ""
  go "build -o #{install_dir}/bin/#{name}#{file_extension}", env: env
end