#
# Copyright 2012-2019, Chef Software Inc.
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
default_version "6.6"

license "MIT"
license_file "http://invisible-island.net/ncurses/ncurses-license.html"
license_file "http://invisible-island.net/ncurses/ncurses.faq.html"
skip_transitive_dependency_licensing true

dependency "config_guess"

# versions_list: https://ftp.gnu.org/gnu/ncurses/ filter=*.tar.gz
version("6.6") { source sha256: "355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11" }
version("6.5") { source sha256: "136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6" }
version("6.4") { source sha256: "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159" }
version("6.3") { source sha256: "97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059" }
version("6.2") { source sha256: "30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d" }
version("6.1") { source sha256: "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17" }
version("5.9") { source sha256: "9046298fb440324c9d4135ecea7879ffed8546dd1b58e59430ea07a4633f563b" }

source url: "https://mirror.team-cymru.com/gnu/ncurses/ncurses-#{version}.tar.gz"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

relative_path "ncurses-#{version}"

########################################################################
#
# wide-character support:
# Ruby 1.9 optimistically builds against libncursesw for UTF-8
# support. In order to prevent Ruby from linking against a
# package-installed version of ncursesw, we build wide-character
# support into ncurses with the "--enable-widec" configure parameter.
# To support other applications and libraries that still try to link
# against libncurses, we also have to create non-wide libraries.
#
# The methods below are adapted from:
# http://www.linuxfromscratch.org/lfs/view/development/chapter06/ncurses.html
#
########################################################################

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env.delete("CPPFLAGS")

  update_config_guess

  if mac_os_x? ||
      # Clang became the default compiler in FreeBSD 10+
      (freebsd? && ohai["os_version"].to_i >= 1000024)
    # References:
    # https://github.com/Homebrew/homebrew-dupes/issues/43
    # http://invisible-island.net/ncurses/NEWS.html#t20110409
    #
    # Patches ncurses for clang compiler. Changes have been accepted into
    # upstream, but occurred shortly after the 5.9 release. We should be able
    # to remove this after upgrading to any release created after June 2012
    patch source: "ncurses-clang.patch", env: env
  end

  configure_command = [
    "./configure",
    "--prefix=#{install_dir}/embedded",
    "--enable-overwrite",
    "--with-shared",
    "--without-ada",
    "--without-cxx-binding",
    "--without-debug",
    "--without-manpages",
  ]

  if aix?
    configure_command << "--with-libtool=\"#{install_dir}/embedded/bin/libtool\""
    configure_command << "--without-normal"
    env.delete("ARFLAGS")
    env["INSTALL"] = "/opt/freeware/bin/install"
  end

  # ncurses 6.4+ changed the build dependency: the non-wide ncurses subdir
  # now depends on libncursesw being present in the build tree. Build widec
  # first so the dependency is satisfied when we build non-wide.
  command (configure_command + ["--enable-widec"]).join(" "), env: env
  make "libs", env: env if aix?
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  make "distclean", env: env

  # After distclean the build-tree lib/ is gone. Restore the widec shared
  # libraries so the non-wide pass can satisfy its ../lib/libncursesw* dep.
  if mac_os_x?
    command "mkdir -p lib && cp #{install_dir}/embedded/lib/libncursesw*.dylib lib/", env: env
  end

  # Build non-wide libraries (for apps that link against -lncurses directly)
  command configure_command.join(" "), env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
