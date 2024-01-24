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
default_version "1.6.652"
linux_sha = "a4f7c46df3b13ff41a451252b7f4abae322cdd77f54f470a5bc06d8da34cdf9e"
darwin_sha = "df5c02dc4fc4a328d81fe7c031a50d13b6c25b1cdd06a51b1713e089378ec7a9"
darwin_m1_sha = "938d333237f600c75ad4ead24777cb1457b9d89288156aba1a56327c8f2be955"
linux_aarch_sha = "423c472275f82ef405d8f06a8cb69bde2e3d4e83c7b91545edc198a53cd73cae"
windows_sha = "14cb43c4eea114207954b54dae488b597f8a61797c8e66722793400d2f5fe85e"
# END DO NOT MODIFY

if windows?
  suffix = "x86_64-windows.zip"
  sha256 = windows_sha
elsif linux?
  if arm?
    suffix = "aarch64-linux.tar.gz"
    sha256 = linux_aarch_sha
  else
    suffix = "x86_64-linux.tar.gz"
    sha256 = linux_sha
  end
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
    puts "install_dir is------#{install_dir}"
    dest = File.join(install_dir, "bin")
    puts "dest is -----#{dest}"
    # We don't just copy the bin itself because on Windows additional
    # supporting DLLs are included.
    puts "project_dir is----#{project_dir}"
    puts "all files are----#{Dir.glob("#{project_dir}/hab-*/*")}"
    Dir.glob("#{project_dir}/hab-*/*").each do |f|
      puts "f is-----#{f}"
      copy f, dest
    end
  end
end
