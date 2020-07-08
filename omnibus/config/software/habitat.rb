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
default_version "latest"
license :project_license
skip_transitive_dependency_licensing true

# DO NOT MODIFY: version and checksums are populated by workstation/.expeditor/update_habitat.sh
version "1.6.56"
linux_sha = "a87f4ff7558f23724289e2c5a9b75920da364818167f63b26411be5a8b344800"
darwin_sha = "42b6c417b88351e0b8ce99cb6ebcc104bbb5bc819ffc795f980d1201068035e6"
windows_sha = "648157f1db680233b676725d3142ef118e5a77da000209a532fb54ff153b57dd"
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

source url: "https://packages.chef.io/files/stable/habitat/latest/hab-x86_64-#{suffix}",
  sha256: sha256

build do
  # 'block' is needed to prevent evaluating the ruby code
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
