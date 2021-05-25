#
# Copyright:: Copyright Chef Software, Inc.
# License:: Apache License, Version 2.0
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
default_version "14.17.0"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "14.17.0" do
  source_hash = if macos?
                  "7b210652e11d1ee25650c164cf32381895e1dcb3e0ff1d0841d8abc1f47ac73e"
                elsif linux?
                  "3d06eabc73ec8626337bff370474306eac1c3c21122f677720d154c556ceafaf"
                elsif windows?
                  "6582a7259c433e9f667dcc4ed3e5d68bc514caba2eed40e4626c8b4c7e5ecd5c"
                else
                  raise "nodejs-binary does not have configuration for this build platform"
                end
  source sha256: source_hash
end

platform_name, platform_ext = if macos?
                                %w{darwin tar.gz}
                              elsif linux?
                                %w{linux tar.gz}
                              elsif windows?
                                %w{win zip}
                              end

source url: "https://nodejs.org/dist/v#{version}/node-v#{version}-#{platform_name}-x64.#{platform_ext}"
relative_path "node-v#{version}-#{platform_name}-x64"

ENV["omnibus_nodejs_dir"] = project_dir
