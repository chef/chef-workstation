name "chef-analyze"
default_version "0.1.191"  # updated to latest version
license "Apache-2.0"
license_file "LICENSE"

# versions_list: https://github.com/chef/chef-analyze/tags filter=*.tar.gz
source url: "https://github.com/chef/chef-analyze/archive/refs/tags/#{default_version}.tar.gz",
       sha256: "de850fc7208d84d9e62d5264df7a6abd3941ebac461faad96cf6fba011ed9b2d"

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