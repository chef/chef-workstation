#
# Copyright:: Copyright Chef Software, Inc.
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

name "habitat"
license :project_license
skip_transitive_dependency_licensing true

# DO NOT MODIFY: default_version and checksums are populated by
#                workstation/.expeditor/update_habitat.sh
default_version "1.6.1243"
linux_sha = "c603cc40c2d0e58b3cbb89e355669a6b54cdd109483ad3440cb00f4aad3e3684"
darwin_sha = "3b8054ee87fa08c12348bb6c661ef140dad100857f0682e84f92a6500edb3add"
darwin_m1_sha = "cf16143aab4c11e869f5f3a9d956fd2bc1e59b9094fd61e78e840235e0ab7503"
windows_sha = "56843f452dfc4d2df42404b4722c184f549e3ad8e66dc69aad1da41bfdccd209"
# END DO NOT MODIFY

if windows?
  suffix = "x86_64-windows.zip"
  sha256 = windows_sha
elsif linux?
  suffix = "x86_64-linux.tar.gz"
  sha256 = linux_sha
elsif mac?
  if arm?
    suffix = "aarch64-darwin.zip"
    sha256 = darwin_m1_sha
  else
    suffix = "x86_64-darwin.zip"
    sha256 = darwin_sha
  end
else
  raise "habitat dep is only available for windows, linux, and mac"
end

source url: "https://packages.chef.io/files/stable/habitat/#{version}/hab-#{suffix}",
  sha256: sha256

build do
  # "block" is needed to prevent evaluating the ruby code
  # before the project_dir contains the extracted package.
  block "Relocating habitat" do
    dest = File.join(install_dir, "bin")
    # We don't just copy the bin itself because on Windows additional
    # supporting DLLs are included.
    Dir.glob("#{project_dir}/hab-*/*").each do |f|
      copy f, dest
    end
  end
end
