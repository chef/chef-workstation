#
# Copyright:: Copyright (c) Chef Software Inc.
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

# This component builds all gems that we distribute as part of chef-workstation.
name "gems"
source path: File.join("#{project.files_path}", "../../components/gems")
license :project_license

dependency "ruby"

#
# NOTE: Do not add any gem dependencies here.  This will cause gemsets to solve without
# the full constrains of chef-workstation, which can result in multiple gem versions
# shipping in the omnibus package.

# However, for gems that depend on c-libs, we must include the c-libraries directly here.

# For nokogiri, archive_file in chef infra client, and berkshelf
dependency "libxml2"
dependency "libxslt"
dependency "liblzma"
dependency "zlib"
dependency "libarchive"

# for train
dependency "google-protobuf"

# This is a transative dep but we need to build from source so binaries are built on current sdk.
# Only matters on mac.
# @todo https://github.com/guard/rb-fsevent/issues/83
dependency "rb-fsevent-gem" if macos?

build do
  env = if !windows?
          with_standard_compiler_flags(with_embedded_path)
        else
          # On windows we use all the compiler flags from the ruby we just built and use
          # the built-in devkit rather than using omnibus-toolchain.  This both works much
          # better at this moment in time, and ensures that we can install gems with the
          # ruby that we just built.
          { "Path" => "#{install_dir}\\embedded\\bin;#{ENV["PATH"]}" }
        end

  #######################################################
  # !!!              IMPORTANT REMINDER             !!! #
  #######################################################
  # Any changes to the gem component ('without' flags,  #
  # additions/removals) must also be updated in in      #
  # habitat/plan.sh                                     #
  #######################################################

  # TODO - reevaluate groups - would like to universally exclude development,
  # testing but we'll need to make sure that's safe and doesn't remove
  # gems that the various applications need for day-to-day functionality.
  excluded_groups = %w{server docgen maintenance pry travis integration ci}

  env["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"

  # install the whole bundle first
  bundle "config set --local without '#{excluded_groups.join(" ")}'", env: env
  bundle "install --jobs 10", env: env

  ruby "post-bundle-install.rb", env: env

  command "gem list"

  appbundle "knife", lockdir: project_dir, gem: "knife", without: %w{development}, env: env
  appbundle "foodcritic", lockdir: project_dir, gem: "chef_deprecations", without: %w{development test}, env: env
  appbundle "delivery", lockdir: project_dir, gem: "chef_deprecations", without: %w{development test}, env: env
  appbundle "test-kitchen", lockdir: project_dir, gem: "test-kitchen", without: %w{changelog debug docs development integration}, env: env
  appbundle "inspec", lockdir: project_dir, gem: "inspec-bin", without: %w{deploy tools maintenance integration}, env: env
  appbundle "chef-run", lockdir: project_dir, gem: "chef-apply", without: %w{development docs debug}, env: env
  appbundle "chef-cli", lockdir: project_dir, gem: "chef-cli", without: %w{development profile test}, env: env
  appbundle "berkshelf", lockdir: project_dir, gem: "berkshelf", without: %w{changelog build docs debug development}, env: env
  appbundle "mixlib-install", lockdir: project_dir, gem: "mixlib-install", without: %w{test chefstyle debug}, env: env
  appbundle "chef-zero", lockdir: project_dir, gem: "chef-zero", without: %w{pedant development debug}, env: env
  appbundle "cookstyle", lockdir: project_dir, gem: "cookstyle", without: %w{docs profiling rubocop_gems development debug}, env: env
  appbundle "fauxhai", lockdir: project_dir, gem: "fauxhai-chef", env: env

  # Note - 'chef-apply' gem provides 'chef-run', not 'chef-apply' which ships with chef-bin...
  %w{chef-bin chef-apply chef-vault ohai}.each do |gem|
    appbundle gem, lockdir: project_dir, gem: gem, without: %w{changelog}, env: env
  end

  # Clear git-checked-out gems (most of this cleanup has been moved into the chef-cleanup omnibus-software definition,
  # but chef-client still needs git-checked-out gems)
  block "Delete bundler git installs" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp
    remove_directory "#{gemdir}/bundler"
  end
end
