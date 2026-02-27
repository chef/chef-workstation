name "chef-analyze"
default_version "0.1.192"  # updated to latest version
license "Apache-2.0"
license_file "LICENSE"

# versions_list: https://github.com/chef/chef-analyze/tags filter=*.tar.gz
source url: "https://github.com/chef/chef-analyze/archive/refs/tags/#{default_version}.tar.gz",
       sha256: "6dfdb5cb8fa71faf8d223f2e03f98cfbd5332f0fe6700fdb3d2528661b10bb3e"

# Update the internal_source URL to match the source URL
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

relative_path "chef-analyze-#{version}"
dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "1"
  file_extension = windows? ? ".exe" : ""
  go "build -o #{install_dir}/bin/#{name}#{file_extension}", env: env
end