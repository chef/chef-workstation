#
# Copyright:: Copyright (c) 2020 Chef Software Inc.
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
default_version "1.6.181"
linux_sha = "efa91792f9d116dd63c481b3d3ee88e65e0cb49f0654578fc93166f614590809"
darwin_sha = "268c149431842a58cdbdcf3e7354f90dec38cd548568520b8a602e48d8d4cbb8"
windows_sha = "097da90435458a2ac2739e12c63bfba55bb4c7ba163b2ae65ab93968e9ced8c3"
# END DO NOT MODIFY

if windows?
  suffix = "windows.zip"
  sha256 = windows_sha
elsif linux?
  suffix = "linux.tar.gz"
  sha256 = linux_sha
elsif mac?
  suffix = "darwin.zip"
  sha256 = darwin_sha
else
  raise "habitat dep is only available for windows, linux, and mac"
end

source url: "https://packages.chef.io/files/stable/habitat/#{version}/hab-x86_64-#{suffix}",
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
