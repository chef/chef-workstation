#
# Copyright:: Copyright (c) Chef Software Inc.
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

# Workaround for a race condition in ncurses 6.4 when building with parallel (-j) jobs on macOS.
# The error is: gmake[1]: *** No rule to make target '../lib/libtinfo.6.dylib', needed by 'all'.
# Solution: Disable parallel make jobs on macOS by lowering the worker count in the environment

name "ncurses"
default_version "6.4"

license "MIT"
license_file "COPYING"

source url: "https://invisible-mirror.net/archives/ncurses/ncurses-#{version}.tar.gz",
       sha256: "6931283d9ac87c5073f30b6290c4c15f3fb1b100d6cbf8b02b6282f7f42a279e"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

relative_path "ncurses-#{version}"

# Patches directory for potential future fixes
# patch source: "ncurses-fix-macos-arm64-race.patch"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # On macOS, set worker count to 1 to avoid parallel make race conditions with libtinfo.6.dylib
  if mac_os_x?
    # Override workers for this build to disable parallel jobs
    env["MAKE"] = "gmake -j 1"
  else
    env["MAKE"] = "gmake -j #{workers}"
  end

  configure_args = [
    "--prefix=#{install_dir}/embedded",
    "--enable-shared",
    "--enable-ext-colors",
    "--enable-ext-mouse",
    "--with-default-terminfo-dir=#{install_dir}/embedded/share/terminfo",
    "--mandir=#{install_dir}/embedded/share/man",
    "--without-ada",
    "--without-tests",
    "--without-progs",
  ]

  configure_cmd = "./configure"
  command "#{configure_cmd} #{configure_args.join(" ")}", env: env

  # Use the MAKE environment variable we set above
  make "install", env: env
end
