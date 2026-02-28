#
# Copyright:: Chef Software, Inc.
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

name "git-windows"
default_version "2.53.0"

license "LGPL-2.1"
# the license file does not ship in the portable git package so pull from the source repo
license_file "https://raw.githubusercontent.com/git-for-windows/git/master/LGPL-2.1"

# Git for Windows dropped 32-bit support starting with version 2.49.0.
# Only 64-bit builds are supported.
arch_suffix = "64"

# The Git for Windows project includes a build number in their tagging
# scheme and therefore in the URLs for downloaded releases.
# Occasionally, something goes wrong with a build/release and the "real"
# release of a version has a build number other than 1. And so far, the
# release URLs have not followed a consistent pattern for whether and how
# the build number is included.
# This URL pattern has worked for most releases. If a version has multiple
# builds, set the `source url:` again explicitly to the one appropriate for
# that version's release.
source url: "https://github.com/git-for-windows/git/releases/download/v#{version}.windows.1/PortableGit-#{version}-#{arch_suffix}-bit.7z.exe"
internal_source url: "https://github.com/git-for-windows/git/releases/download/v#{version}.windows.1/PortableGit-#{version}-#{arch_suffix}-bit.7z.exe"

# version_list: url=https://github.com/git-for-windows/git/releases filter=PortableGit-*-64-bit.7z.exe
version("2.53.0") { source sha256: "08713a710ec91ac90de1c09f861289a3b103175f098676e5e664c04dd6c6bf23" }
version("2.49.1") { source sha256: "643def94eaa15215ebe1018804d2ac3a458e80a2fc27aef6e5139411728f3a7d" }
version("2.48.1") { source sha256: "a4335111b3363871cac632be93d7466154d8eb08782ff55103866b67d6722257" }

# The git portable archives come with their own copy of posix related tools
# i.e. msys/basic posix/what-do-you-mean-you-dont-have-bash tools that git
# needs.  Surprising nobody who has ever dealt with this on windows, we ship
# our own set of posix libraries and ported tools - the highlights being
# tar.exe, sh.exe, bash.exe, perl.exe etc.  Since our tools reside in
# embedded/bin, we cannot simply extract git's bin/ cmd/ and lib directories
# into embedded.  So we we land them in embedded/git instead.  Git uses a
# strategy similar to ours when it comes to "appbundling" its binaries.  It has
# a /bin top level directory and a /cmd directory.  The unixy parts of it use
# /bin.  The windowsy parts of it use /cmd.  If you add /cmd to the path, there
# are tiny shim-executables in there that forward your call to the appropriate
# internal binaries with the path and environment reconfigured correctly.
# Unfortunately, they work based on relative directories...  so /cmd/git.exe
# looks for ../bin/git.  If we want delivery-cli or other applications to access
# git binaries without having to add yet another directory to the system path,
# we need to add our own shims (or shim-shims as I like to call them).  These
# are .bat files in embedded/bin - one for each binary in git's /cmd directory -
# that simply call out to git's shim binaries.

build do

  env = with_standard_compiler_flags(with_embedded_path)

  source_7z = "#{project_dir}/PortableGit-#{version}-#{arch_suffix}-bit.7z.exe"
  destination = "#{install_dir}/embedded/git"

  command "#{source_7z} -y"
  sync "PortableGit", "#{windows_safe_path(destination)}", env: env

  block "Create bat files to point to executables under embedded/git/cmd" do
    Dir.glob("#{destination}/cmd/*") do |git_bin|
      ext = File.extname(git_bin)
      base = File.basename(git_bin, ext)
      File.open("#{install_dir}/embedded/bin/#{base}.bat", "w") do |f|
        f.puts "@ECHO OFF"
        f.print "START \"\" " if %w{gitk git-gui}.include?(base.downcase)
        f.puts "\"%~dp0..\\git\\cmd\\#{base}#{ext}\" %*"
      end
    end
  end
end
