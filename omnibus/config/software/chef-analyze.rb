name "chef-analyze"
default_version "0.1.190"  # updated to latest version
license "Apache-2.0"
license_file "LICENSE"

# versions_list: https://github.com/chef/chef-analyze/tags filter=*.tar.gz
source url: "https://github.com/chef/chef-analyze/archive/refs/tags/#{default_version}.tar.gz",
       sha256: "eb06e4adf786affcdaad0cd36ebac4d5cad5783fefdc60ea9591b71a7ea38631"

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