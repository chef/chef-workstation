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
default_version "1.6.420"
linux_sha = "2718ac16e8872bf058d47004b1242574f26a49886a9b52e8cbbad3023cd6e314"
darwin_sha = "1dd86170bbbc3a93ea7a88cb32f2b0e9f1ce30dffc9ef316f25103a7c497a5de"
darwin_m1_sha = "5ce236f449f2d4bc1134a7946171069ad69a61e761124614dab52de65618ff8f"
windows_sha = "865f7dc2c079ca8e8d0fbcd8998451ee4e0fa905c10e053809d39d5195039b81"
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
