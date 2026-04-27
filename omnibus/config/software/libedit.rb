# Copyright 2012-2014 Chef Software, Inc.
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
# Forked from omnibus-software to add the macOS gawk LANG fix:
# libedit's makelist uses `AWK=gawk sh ./makelist` and gawk 4.4+ on macOS
# silently mishandles character class regex when LANG is unset. The ncurses
# build step (which runs first, as ncurses is a dependency) writes a gawk
# wrapper to #{install_dir}/embedded/bin/gawk-lang-wrapper; we point AWK
# to it so configure embeds the wrapper path in the generated Makefile.

name "libedit"
default_version "20120601-3.0"

license "BSD-3-Clause"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "ncurses"
dependency "config_guess"

# version_list: url=http://thrysoee.dk/editline/ filter=*.tar.gz

version("20221030-3.1") { source sha256: "f0925a5adf4b1bf116ee19766b7daa766917aec198747943b1c4edf67a4be2bb" }
version("20210910-3.1") { source sha256: "6792a6a992050762edcca28ff3318cdb7de37dccf7bc30db59fcd7017eed13c5" }
version("20210419-3.1") { source sha256: "571ebe44b74860823e24a08cf04086ff104fd7dfa1020abf26c52543134f5602" }
version("20150325-3.1") { source sha256: "c88a5e4af83c5f40dda8455886ac98923a9c33125699742603a88a0253fcc8c5" }
version("20141030-3.1") { source sha256: "9701e16570fb8f7fa407b506986652221b701a9dd61defc05bb7d1c61cdf5a40" }
version("20130712-3.1") { source sha256: "5d9b1a9dd66f1fe28bbd98e4d8ed1a22d8da0d08d902407dcc4a0702c8d88a37" }
version("20120601-3.0") { source sha256: "51f0f4b4a97b7ebab26e7b5c2564c47628cdb3042fd8ba8d0605c719d2541918" }

source url: "https://www.thrysoee.dk/editline/libedit-#{version}.tar.gz"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

if version == "20141030-3.1"
  # released tar file has name discrepency in folder name for this version
  relative_path "libedit-20141029-3.1"
else
  relative_path "libedit-#{version}"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # The patch is from the FreeBSD ports tree and is for GCC compatibility.
  # http://svnweb.freebsd.org/ports/head/devel/libedit/files/patch-vi.c?annotate=300896
  if version.to_i < 20150325 && (freebsd? || openbsd?)
    patch source: "freebsd-vi-fix.patch", env: env
  end

  if openbsd?
    patch source: "openbsd-weak-alias-fix.patch", plevel: 1, env: env
  elsif aix?
    env["LC_ALL"] = "en_US"
  end

  if solaris2?
    patch source: "solaris.patch", plevel: 1, env: env
  end

  if mac_os_x?
    # gawk-lang-wrapper is created by the ncurses build step (ncurses is a
    # dependency so it always runs first). It forces LANG=C before exec'ing
    # the real gawk, working around the gawk 4.4+ macOS bug where [+] in a
    # regex character class is misinterpreted as an ERE quantifier when LANG
    # is unset. libedit's Makefile picks up AWK from configure, so passing it
    # here ensures `AWK=gawk-lang-wrapper sh ./makelist ...` in the Makefile.
    env["AWK"] = "#{install_dir}/embedded/bin/gawk-lang-wrapper"
  end

  if linux?
    # libedit configure searches for tgetent in -ltinfo first, then -lncurses.
    # Even with -L/embedded/lib, libtool (the actual linker) falls back to the
    # SYSTEM libtinfo.so.6 because there is no embedded libtinfo.la file to
    # tell it to use our embedded library. The resulting libedit.so records a
    # runtime dependency on the system libtinfo.so.6, which omnibus health check
    # rejects as unsafe. Fix: pre-cache the autoconf result for -ltinfo as "no"
    # so configure falls through to -lncurses, which IS in the embedded lib.
    env["ac_cv_lib_tinfo_tgetent"] = "no"
  end

  update_config_guess

  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
