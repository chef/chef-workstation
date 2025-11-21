#
# Copyright 2018 Chef Software, Inc.
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

### NOTE ###
# We build this definition from source rather than installing from the
# gem so the native extension builds against the correct ruby rather than shipping
# a vendored library for each 2.x version of ruby, which is what is packaged
# with the gem.

name "google-protobuf"
default_version "3.25.5"

dependency "ruby"

source git: "https://github.com/google/protobuf.git"

# versions_list: https://github.com/protocolbuffers/protobuf/tags filter=*.tar.gz
version("3.25.5") do
  source sha256: "4356e78744dfb2df3890282386c8568c85868116317d9b3ad80eb11c2aecf2ff"
  source url: "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.25.5.tar.gz"
  internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/protobuf-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"
end

relative_path "protobuf-#{version}"

license :project_license

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # EL-7 (RHEL/CentOS 7) uses GCC 4.8.5 which doesn't support C11's stdatomic.h
  # google-protobuf 3.25.5+ requires C11 support (specifically _Atomic and stdatomic.h)
  # For el-7, we use the pre-compiled binary gem from RubyGems which was built with C11 support
  if rhel? && platform_version.satisfies?("< 8.0")
    gem "install google-protobuf --version #{version} --no-document", env: env
  else
    # Build from source for all other platforms
    mkdir "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"
    copy "#{project_dir}/third_party/utf8_range/utf8_range.h",  "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"
    copy "#{project_dir}/third_party/utf8_range/naive.c",       "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"
    copy "#{project_dir}/third_party/utf8_range/range2-neon.c", "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"
    copy "#{project_dir}/third_party/utf8_range/range2-sse.c",  "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"
    copy "#{project_dir}/third_party/utf8_range/LICENSE",       "#{project_dir}/ruby/ext/google/protobuf_c/third_party/utf8_range"

    gem "build google-protobuf.gemspec", env: env, cwd: "#{project_dir}/ruby"
    gem "install google-protobuf-*.gem", env: env, cwd: "#{project_dir}/ruby"
  end
end