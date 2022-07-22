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
default_version "1.6.521"
linux_sha = "5b3ffa030817cb236319bba534632d2a65cdd6cf9b8262559427dfe07bc56af2"
darwin_sha = "7d83af8e267bed3865be3be102a21040fa03555dcf76f9d6f220dd66e614aa8c"
darwin_m1_sha = "1fac2a9560c2da917d46bb81a3ae6debb8911d6f41dda1b12579de5e1e8150b1"
windows_sha = "94cb1cbeb557b42ac1d46a9ae9d444372ae0caef86d6e9b0284998dd006e821c"
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
