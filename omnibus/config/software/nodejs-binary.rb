#
# Copyright 2018-2019 Chef Software, Inc.
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

#
# nodejs-binary provides nodejs using the binary packages provided by
# the upstream.  Because this is for build-time use only, it does not does
# not install it into `install_dir` and so does not need to be cleaned up.
# Instead, it's  instead it's retained in the build cache location.
#
# The specific path is shared via the environment variable `omnibus_nodejs_dir`
# which gets set when this software definition is loaded.
#
# To use the nodejs binaries (npm, node) first ensure this is a dependency for
# your component; then:
#   *nix, mac,  add ENV['omnibus_nodejs_dir']/bin to the PATH within the `build` block.
#   * For Windows, add ENV['omnibus_nodejs_dir']  and do not append '\bin'
#
#
# To ensure no ordering issues around load v build time resolution,
# it may be necessary to include a `block in your `build` block.
# Here's an example:
# ```
# build do
#  block "stuff-to-run-only-after-all-definitions-are-loaded" do
#   env = with_standard_compiler_flags(with_embedded_path)
#   node_tools_dir = ENV['omnibus_nodejs_dir']
#   node_bin_path = windows? ? node_tools_dir : File.join(node_tools_dir, "bin")
#   separator = File::PATH_SEPARATOR || ":"
#   env['PATH'] = "#{env['PATH']}#{separator}#{node_bin_path}"
#   command "npm build", env: env
#  end
# end
# ```

name "nodejs-binary"
default_version "11.15.0"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "10.16.3" do
  source_hash = if mac_os_x?
                  "6febc571e1543c2845fa919c6d06b36a24e4e142c91aedbe28b6ff7d296119e4"
                elsif linux?
                  "2f0397bb81c1d0c9901b9aff82a933257bf60f3992227b86107111a75b9030d9"
                elsif windows?
                  "19aa47de7c5950d7bd71a1e878013b98d93871cc311d7185f5472e6d3f633146"
                else
                  raise "nodejs-binary does not have configuration for this build platform"
                end
  source sha256: source_hash
end

version "11.15.0" do
  source_hash = if mac_os_x?
                  "e953b657b1049e1de509a3fd0700cfeecd175f75a0d141d71393aa0d71fa29a9"
                elsif linux?
                  "98bd18051cbdb39bbcda1ab169ca3fd3935d87e9cfc36e1b6fd6f609d46856bb"
                elsif windows?
                  "f3cef50acf566724a5ec5df7697fb527d7339cafdae6c7c406a39358aee6cdf8"
                else
                  raise "nodejs-binary does not have configuration for this build platform"
                end
  source sha256: source_hash
end

# We cannot upgrade to > 11 until we drop EL 6 support.
# https://github.com/nodejs/node/blob/v12.x/BUILDING.md#supported-toolchains
# NodeJS 12 requires Kernel >= 3.10
# https://docs.chef.io/release_notes/#red-hat--centos-6-systems-require-c11-gcc-for-some-gem-installations
version "14.1.0" do
  source_hash = if mac_os_x?
                  "7f08bd365df4e7a5625ad393257f48e8cd79f77391ab87a64426b0c6448dd226"
                elsif linux?
                  "0edca22822d86a1626707e19a5b2e17f1dbf4f3ac553ac3368aab3bb24de68bf"
                elsif windows?
                  "1d3890d0d2f996cce57bcb0206e49b67233623e3cdb50eee77b8acc8f006b955"
                else
                  raise "nodejs-binary does not have configuration for this build platform"
                end
  source sha256: source_hash
end

platform_name, platform_ext = if mac_os_x?
                                %w{darwin tar.gz}
                              elsif linux?
                                %w{linux tar.gz}
                              elsif windows?
                                %w{win zip}
                              end

source url: "https://nodejs.org/dist/v#{version}/node-v#{version}-#{platform_name}-x64.#{platform_ext}"
relative_path "node-v#{version}-#{platform_name}-x64"

ENV["omnibus_nodejs_dir"] = project_dir
