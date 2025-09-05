#
# Copyright 2019 Chef Software, Inc.
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

name "go"
default_version "1.23.12"
license "BSD-3-Clause"
license_file "https://raw.githubusercontent.com/golang/go/master/LICENSE"

# Defaults
arch = "amd64"

if windows?
  platform = "windows"
  ext = "zip"

  # version_list: url=https://golang.org/dl/ filter=*.windows-amd64.zip
  version("1.23.12") { source sha256: "07c35866cdd864b81bb6f1cfbf25ac7f87ddc3a976ede1bf5112acbb12dfe6dc" }
  source url: "https://dl.google.com/go/go#{version}.%{platform}-%{arch}.%{ext}" % { platform: platform, arch: arch, ext: ext }
  internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.%{platform}-%{arch}.%{ext}",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

elsif mac_os_x?
  # platform = "darwin"
  if intel?
    # arch = "amd64"
    version "1.23.12" do
      source url: "https://artifactory-internal.ps.chef.co/artifactory/omnibus-software-local/go/go1.23.12.darwin-amd64.tar.gz",
             sha256: "0f6efdc3ffc6f03b230016acca0aef43c229de022d0ff401e7aa4ad4862eca8e"
    end
  else
    # arch = "arm64"
    version "1.23.12" do
      source url: "https://artifactory-internal.ps.chef.co/artifactory/omnibus-software-local/go/go1.23.12.darwin-arm64.tar.gz",
             sha256: "5bfa117e401ae64e7ffb960243c448b535fe007e682a13ff6c7371f4a6f0ccaa"
    end
  end

elsif armhf?
  # arch = "armv6l"
  version("1.23.12") { source sha256: "9704eba01401a3793f54fac162164b9c5d8cc6f3cab5cee72684bb72294d9f41" }

  source url: "https://artifactory-internal.ps.chef.co/artifactory/omnibus-software-local/#{name}/#{name}#{version}.linux-armv6l.tar.gz"

  internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.%{platform}-%{arch}.%{ext}",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

elsif arm?
  # arch = "arm64"
  # version_list: url=https://golang.org/dl/ filter=*.linux-arm64.tar.gz
  version("1.23.12") { source sha256: "52ce172f96e21da53b1ae9079808560d49b02ac86cecfa457217597f9bc28ab3" }

  source url: "https://artifactory-internal.ps.chef.co/artifactory/omnibus-software-local/#{name}/#{name}#{version}.linux-arm64.tar.gz"

  internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.%{platform}-%{arch}.%{ext}",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

else
  # version_list: url=https://golang.org/dl/ filter=*.linux-amd64.tar.gz
  version("1.23.12") { source sha256: "d3847fef834e9db11bf64e3fb34db9c04db14e068eeb064f49af747010454f90" }
end

source url: "https://artifactory-internal.ps.chef.co/artifactory/omnibus-software-local/#{name}/#{name}#{version}.linux-amd64.tar.gz"

internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.%{platform}-%{arch}.%{ext}",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

build do
  # We do not use 'sync' since we've found multiple errors with other software definitions
  mkdir "#{install_dir}/embedded/go"
  copy "#{project_dir}/go/*", "#{install_dir}/embedded/go"

  mkdir "#{install_dir}/embedded/bin"
  %w{go gofmt}.each do |bin|
    link "#{install_dir}/embedded/go/bin/#{bin}", "#{install_dir}/embedded/bin/#{bin}"
  end
end
