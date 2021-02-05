#
# Copyright 2018-2021 Chef Software, Inc.
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
default_version "14.15.4"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "14.15.4" do
  source_hash = if mac_os_x?
                  "6b0e19e5c2601ef97510f7eb4f52cc8ee261ba14cb05f31eb1a41a5043b0304e"
                elsif linux?
                  "b51c033d40246cd26e52978125a3687df5cd02ee532e8614feff0ba6c13a774f"
                elsif windows?
                  "b2a0765240f8fbd3ba90a050b8c87069d81db36c9f3745aff7516e833e4d2ed6"
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
