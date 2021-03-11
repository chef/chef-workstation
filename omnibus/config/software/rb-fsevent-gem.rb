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

# The author built their binary against an old SDK version and signing
# only supports SDK version >= 10.9, so we must rebuild and install.

name "rb-fsevent-gem"
default_version "master"

# this is a fork that has patches for m1 macs
# we should switch back to the gem install when this is all released
source git: "https://github.com/imajes/rb-fsevent.git", branch: "add-support-for-m1"

license "Apache-2.0"
# this is a fork that has patches for m1 macs
license_file "https://raw.githubusercontent.com/imajes/rb-fsevent/master/LICENSE.txt"

dependency "ruby"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  # Look up active sdk version.
  sdk_ver = `xcrun --sdk macosx --show-sdk-version`.strip
  # Newer versions of xcode on MacOS 10.15 returns a full semver so see if we
  # have a full semver and account for that.
  ver = Gem::Version.new(sdk_ver)
  if ver.canonical_segments.count < 3
    env["MACOSX_DEPLOYMENT_TARGET"] = sdk_ver
  else
    env["MACOSX_DEPLOYMENT_TARGET"] = "#{ver.canonical_segments[0]}.#{ver.canonical_segments[1]}"
  end

  # We specifically don't want to install the rb-fsevent deps into the Workstation
  # bundle because it causes dependency conflicts. But we probably need to
  # bundle install so we ensure we have rake available to run the replace_exe task.
  # After running that we build and install the gem manually while excluding
  # dependencies (so we don't bring in conflicts).
  bundle "config set --local path vendor", env: env
  bundle "install", env: env
  bundle "exec rake replace_exe", env: env, cwd: "#{project_dir}/ext"
  gem "build rb-fsevent.gemspec", env: env
  gem "install rb-fsevent-*.gem --no-document --ignore-dependencies", env: env
end
