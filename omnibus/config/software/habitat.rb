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
default_version "1.6.416"
linux_sha = "2532dc6b64c5bc0540abe12d0af82cffe1e203e368a271c0b0a500040b101bea"
darwin_sha = "a8aa9d064df1b7c43c41634284664b6a537e3ef9f76381405b8cbac077331213"
windows_sha = "46a69e53cd6df06f2bdd2297fc563c2652ab17f9fdf305a3795b02abcbea25df"
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
