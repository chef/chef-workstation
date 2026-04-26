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

name "ncurses"
default_version "6.4"

license "MIT"
license_file "COPYING"

source url: "https://invisible-mirror.net/archives/ncurses/ncurses-#{version}.tar.gz",
       sha256: "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

relative_path "ncurses-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env.delete("CPPFLAGS")

  # On macOS, use -j 1 to avoid a parallel make race condition where libtinfo.6.dylib
  # is not yet assembled when sub-makes try to link against it.
  # Setting env["MAKE"] does NOT work — omnibus's make DSL ignores the MAKE env var
  # and invokes make directly, so we pass the -j flag explicitly.
  j = mac_os_x? ? "-j 1" : "-j #{workers}"

  configure_args = [
    "./configure",
    "--prefix=#{install_dir}/embedded",
    "--enable-shared",
    "--enable-overwrite",
    "--with-termlib",
    "--enable-ext-colors",
    "--enable-ext-mouse",
    "--with-default-terminfo-dir=#{install_dir}/embedded/share/terminfo",
    "--mandir=#{install_dir}/embedded/share/man",
    "--without-ada",
    "--without-tests",
    "--without-progs",
  ]

  # First pass: non-wide libraries
  command configure_args.join(" "), env: env
  make j, env: env
  make "#{j} install", env: env

  # Second pass: wide-character libraries (required by Ruby 1.9+ for UTF-8 / ncursesw)
  make "distclean", env: env
  configure_args << "--enable-widec"
  command configure_args.join(" "), env: env
  make j, env: env
  make "#{j} install", env: env
end
