#
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

name "gecode"
default_version "3.7.3"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

# version_list: url=https://github.com/Gecode/gecode/releases/ filter=gecode-release-*.tar.gz

version("3.7.3") { source sha256: "75faaaa025a154ec0aef8b3b6ed9e78113efb543a92b8f4b2b971a0b0e898108" }
version("3.7.1") { source sha256: "e8d1404929a707efe39d3e93403ef9019e416d90841f76d73fb4466095922c48" }

# Major version, have not tried yet
version("6.2.0") { source sha256: "27d91721a690db1e96fa9bb97cec0d73a937e9dc8062c3327f8a4ccb08e951fd" }
version("5.1.0") { source sha256: "77863f4638c6b77d24a29bf6aeac370c56cd808fe9aabc1fca96655581f6c83d" }
version("4.4.0") { source sha256: "ca261c6c876950191d4ec2f277e5bfee1c3eae8a81af9b5c970d9b0c2930db37" }

source url: "https://github.com/Gecode/gecode/archive/refs/tags/release-#{version}.tar.gz"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

relative_path "gecode-release-#{version}"

build do
  # Add these special flags for all macOS 12+ systems
  if mac_os_x?
    env = with_standard_compiler_flags(with_embedded_path)
    
    # Add C++11 standard and silence deprecation warnings for all macOS builds
    env["CXXFLAGS"] = "#{env["CXXFLAGS"]} -std=c++11 -Wno-deprecated-copy -Wno-new-returns-null"
    
    # Add architecture-specific flags for arm64 (Apple Silicon)
    if ohai['kernel']['machine'] == 'arm64'
      env["CXXFLAGS"] = "#{env["CXXFLAGS"]} -arch arm64"
      env["LDFLAGS"] = "#{env["LDFLAGS"]} -arch arm64"
    end
    
    # Configure with the enhanced environment
    configure_command = [
      "./configure",
      "--prefix=#{install_dir}/embedded",
      "--disable-doc-dot",
      "--disable-doc-search",
      "--disable-doc-tagfile",
      "--disable-doc-chm",
      "--disable-doc-docset",
      "--disable-qt",
      "--disable-examples",
      "--disable-flatzinc",
    ]
    
    command configure_command.join(" "), env: env
  else
    env = with_standard_compiler_flags(with_embedded_path)

    # On some RHEL-based systems, the default GCC that's installed is 4.1. We
    # need to use 4.4, which is provided by the gcc44 and gcc44-c++ packages.
    # These do not use the gcc binaries so we set the flags to point to the
    # correct version here.
    if File.exist?("/usr/bin/gcc44")
      env["CC"]  = "gcc44"
      env["CXX"] = "g++44"
    end

    # Insert patch here
    puts "**********Patch to get the auxilary file **********"
    config_scripts = %w[config.guess config.sub]
    config_scripts.each do |script|
      brew_path = "/opt/homebrew/opt/automake/libexec/gnubin/#{script}"
      gnu_path = "/usr/local/opt/automake/libexec/gnubin/#{script}"
      system_path = `which #{script}`.strip
      src = if File.exist?(brew_path)
        brew_path
      elsif File.exist?(gnu_path)
        gnu_path
      elsif !system_path.empty?
        system_path
      else
        nil
      end
      if src && File.exist?(src)
        FileUtils.cp(src, File.join(build_dir, script))
      end
    end
    
    command "./configure" \
            " --prefix=#{install_dir}/embedded" \
            " --disable-doc-dot" \
            " --disable-doc-search" \
            " --disable-doc-tagfile" \
            " --disable-doc-chm" \
            " --disable-doc-docset" \
            " --disable-qt" \
            " --disable-examples", env: env
  end

  make "-j #{workers}", env: env
  make "install", env: env
end
