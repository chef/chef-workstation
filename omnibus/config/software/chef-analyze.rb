name "chef-analyze"
default_version "0.1.187"  # updated to latest version
license "Apache-2.0"
license_file "LICENSE"

# versions_list: https://github.com/chef/chef-analyze/tags filter=*.tar.gz
source url: "https://github.com/chef/chef-analyze/archive/refs/tags/#{default_version}.tar.gz",
       sha256: "b0a97ee948c312ec97c0acf4ab8f29b5806afc91292279f2bcd10504e890a7cb"

# Update the internal_source URL to match the source URL
internal_source url: "https://github.com/chef/chef-analyze/archive/refs/tags/#{default_version}.tar.gz"

dependency "go"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CGO_ENABLED"] = "1"
  file_extension = windows? ? ".exe" : ""
  go "build -o #{install_dir}/bin/#{name}#{file_extension}", env: env
end