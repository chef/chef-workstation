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

default_version "3.4.1"  # We are using OpenSSL 3.4.1

# Openssl builds engines as libraries into a special directory. We need to include
# that directory in lib_dirs so omnibus can sign them during macOS deep signing.
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/engines"])
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/engines-3"])
lib_dirs lib_dirs.concat(["#{install_dir}/embedded/lib/ossl-modules"])

# Source URL for OpenSSL 3.4.1 (latest release)
source url: "https://www.openssl.org/source/openssl-#{version}.tar.gz", extract: :lax_tar
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz", extract: :lax_tar,
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

version("3.4.1") { source sha256: "002a2d6b30b58bf4bea46c43bdd96365aaf8daa6c428782aa4feee06da197df3" }

relative_path "openssl-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  if mac_os_x? && arm?
    env["CFLAGS"] << " -Qunused-arguments"
  elsif windows?
    env["CFLAGS"] = "-I#{install_dir}/embedded/include"
    env["CPPFLAGS"] = env["CFLAGS"]
    env["CXXFLAGS"] = env["CFLAGS"]
  end

  # Configure and Build OpenSSL 3.4.1 (default version)
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

  # Patches and configurations
  patch source: "openssl-3.4.1-do-not-install-docs.patch", env: env
  configure_args << "enable-legacy"
  patch source: "openssl-3.4.1-enable-legacy-provider.patch", env: env

  configure_args << env["CFLAGS"]
  configure_command = configure_args.unshift(configure_cmd).join(" ")

  command configure_command, env: env, in_msys_bash: true
  make "depend", env: env
  make env: env
  make "install", env: env

  if fips_mode?
    # FIPS-specific steps only executed when fips_mode is enabled

    # Step 1: Download and build OpenSSL 3.0.9 (FIPS validated version)
    fips_version = "3.0.9"
    fips_source_url = "https://www.openssl.org/source/openssl-#{fips_version}.tar.gz"
    fips_relative_path = "openssl-#{fips_version}"

    # Download and extract the OpenSSL 3.0.9 tarball
    unless system("wget #{fips_source_url}")
      raise "Failed to download OpenSSL #{fips_version}!"
    end
    command "tar -xf openssl-#{fips_version}.tar.gz", env: env

    # Build OpenSSL 3.0.9 with FIPS
    Dir.chdir(fips_relative_path) do
      command "./Configure enable-fips", env: env
      make "depend", env: env
      make env: env
    end

    # Step 2: Copy FIPS provider artifacts (fips.so or fips.dll) from OpenSSL 3.0.9
    fips_module_file = "#{install_dir}/embedded/lib/ossl-modules/fips.#{windows? ? 'dll' : 'so'}"
    fips_cnf_file = "#{install_dir}/embedded/ssl/fipsmodule.cnf"

    command "cp #{fips_relative_path}/providers/fips.#{windows? ? 'dll' : 'so'} #{fips_module_file}", env: env
    command "cp #{fips_relative_path}/providers/fipsmodule.cnf #{fips_cnf_file}", env: env

    # Step 3: Validate FIPS provider is active in OpenSSL 3.4.1
    command "#{install_dir}/embedded/bin/openssl list -provider-path #{install_dir}/embedded/lib/ossl-modules -provider fips -providers", env: env

    # Step 4: Run tests using the OpenSSL 3.0.9 FIPS provider
    make "tests", env: env

    # Step 5: Install FIPS provider artifacts to known locations
    command "sudo make install_fips", env: env
  end

  command "#{install_dir}/embedded/bin/openssl list -providers"
end
