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

name "openssl"

license "OpenSSL"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "cacerts"
dependency "openssl-fips" if fips_mode?

default_version "3.2.4"

# Openssl builds engines as libraries into a special directory. We need to include
# that directory in lib_dirs so omnibus can sign them during macOS deep signing.
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/engines"])
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/engines-3"])
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/ossl-modules"])

# Source URL for OpenSSL 3.2.4
source url: "https://www.openssl.org/source/openssl-#{version}.tar.gz", extract: :lax_tar
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz", extract: :lax_tar,
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

version("3.2.4") { source sha256: "b23ad7fd9f73e43ad1767e636040e88ba7c9e5775bfa5618436a0dd2c17c3716" }

relative_path "openssl-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  if mac_os_x? && arm?
    env["CFLAGS"] << " -Qunused-arguments"
  elsif windows?
    # XXX: OpenSSL explicitly sets -march=i486 and expects that to be honored.
    # It has OPENSSL_IA32_SSE2 controlling whether it emits optimized SSE2 code
    # and the 32-bit calling convention involving XMM registers is...  vague.
    # Do not enable SSE2 generally because the hand optimized assembly will
    # overwrite registers that mingw expects to get preserved.
    env["CFLAGS"] = "-I#{install_dir}/embedded/include"
    env["CPPFLAGS"] = env["CFLAGS"]
    env["CXXFLAGS"] = env["CFLAGS"]
  end

  configure_args = [
    "--prefix=#{install_dir}/embedded",
    "no-unit-test",
    "no-comp",
    "no-idea",
    "no-mdc2",
    "no-rc5",
    "no-ssl2",
    "no-ssl3",
    "no-zlib",
    "shared",
    "--libdir=#{install_dir}/embedded/lib",
  ]

  configure_args += ["enable-fips"] if fips_mode?

  configure_cmd =
    if mac_os_x?
      intel? ? "./Configure darwin64-x86_64-cc" : "./Configure darwin64-arm64-cc no-asm"
    elsif windows?
      platform = windows_arch_i386? ? "mingw" : "mingw64"
      "perl.exe ./Configure #{platform}"
    else
      prefix =
        if linux? && ppc64?
          "./Configure linux-ppc64"
        elsif linux? && s390x?
          # With gcc > 4.3 on s390x there is an error building
          # with inline asm enabled
          "./Configure linux64-s390x -DOPENSSL_NO_INLINE_ASM"
        else
          "./config"
        end
      "#{prefix} disable-gost"
    end

  # Patches
  patch source: "openssl-3.2.4-do-not-install-docs.patch", env: env
  # Some of the algorithms which are being used are deprecated in OpenSSL3 and moved to legacy provider.
  # We need those algorithms for the working of chef-workstation and other packages.
  # This patch will enable the legacy providers!
  configure_args << "enable-legacy"
  patch source: "openssl-3.2.4-enable-legacy-provider.patch", env: env

  # Out of abundance of caution, we put the feature flags first and then
  # the crazy platform specific compiler flags at the end.
  configure_args << env["CFLAGS"]

  configure_command = configure_args.unshift(configure_cmd).join(" ")

  command configure_command, env: env, in_msys_bash: true

  make "depend", env: env
  # make -j N on openssl is not reliable
  make env: env
  make "install", env: env

  if fips_mode?

    openssl_fips_version = "3.0.9"

    # Downloading the openssl-3.0.9.tar.gz file and extracting it
    command "wget https://www.openssl.org/source/openssl-#{openssl_fips_version}.tar.gz"
    command "tar -xf openssl-#{openssl_fips_version}.tar.gz"

    # Configuring the fips provider
    if windows?
      platform = windows_arch_i386? ? "mingw" : "mingw64"
      command "cd openssl-#{openssl_fips_version} && perl.exe Configure #{platform} enable-fips"
    else
      command "cd openssl-#{openssl_fips_version} && ./Configure enable-fips"
    end

    # Building the fips provider
    command "cd openssl-#{openssl_fips_version} && make"

    fips_provider_path = "#{install_dir}/embedded/lib/ossl-modules/fips.#{windows? ? "dll" : "so"}"
    fips_cnf_file = "#{install_dir}/embedded/ssl/fipsmodule.cnf"

    # Running the `openssl fipsinstall -out fipsmodule.cnf -module fips.so` command
    command "#{install_dir}/embedded/bin/openssl fipsinstall -out #{fips_cnf_file} -module #{fips_provider_path}"

    # Copying the fips provider and fipsmodule.cnf file to the embedded directory
    command "cp openssl-#{openssl_fips_version}/providers/fips.#{windows? ? "dll" : "so"} #{install_dir}/embedded/lib/ossl-modules/"
    command "cp openssl-#{openssl_fips_version}/providers/fipsmodule.cnf #{install_dir}/embedded/ssl/"

    # Updating the openssl.cnf file to enable the fips provider
    command "sed -i -e 's|# .include fipsmodule.cnf|.include #{fips_cnf_file}|g' #{install_dir}/embedded/ssl/openssl.cnf"
    command "sed -i -e 's|# fips = fips_sect|fips = fips_sect|g' #{install_dir}/embedded/ssl/openssl.cnf"
  end

  command "#{install_dir}/embedded/bin/openssl list -providers"
end