# Copyright:: Copyright (c) 2019 Chef Software Inc.
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
dependency "rubygems"
# Remove? - r26 ships with bundler
dependency "bundler" # technically a gem, but we gotta solve the chicken-egg problem here

#
# NOTE: Do not add any gem dependencies here.  This will cause gemsets to solve without
# the full constrains of chef-workstation, which can result in multiple gem versions
# shipping in the omnibus package.

# However, for gems that depend on c-libs, we must include the c-libraries directly here.

# For nokogiri
dependency "libxml2"
dependency "libxslt"
dependency "liblzma"
dependency "zlib"
dependency "libarchive"

# For berkshelf
dependency "libarchive"

# For opscode-pushy-client
dependency "libzmq"

# for train
dependency "google-protobuf"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # TODO - reevaluate groups
  excluded_groups = %w{server docgen maintenance pry travis integration ci}

  env["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"

  # install the whole bundle first
  bundle "install --jobs 10 --without #{excluded_groups.join(" ")}", env: env

  # TODO - we'll want a better way to manage this - likely some kind of callback
  # from chef-cli so that we can hook in our own version output.
  #
  # Cross platform way to sed. Need to cleanup the backup fail.
  # command("sed -i.bak 's/\\$CHEF_WS_VERSION\\$/#{project.build_version}/' #{project_dir}/lib/chef-dk/cli.rb", env: env)
  # command("rm #{project_dir}/lib/chef-dk/cli.rb.bak")
  appbundle "chef", lockdir: project_dir, gem: "chef", without: %w{docgen chefstyle}, env: env

  appbundle "foodcritic", lockdir: project_dir, gem: "foodcritic", without: %w{development test}, env: env
  appbundle "test-kitchen", lockdir: project_dir, gem: "test-kitchen", without: %w{changelog debug docs development}, env: env
  appbundle "inspec", lockdir: project_dir, gem: "inspec-bin", without: %w{deploy tools maintenance integration}, env: env
  appbundle "chef-run", lockdir: project_dir, gem: "chef-apply", without: %w{changelog docs debug}, env: env
  appbundle "chef-cli", lockdir: project_dir, gem: "chef-cli", without: %w{changelog docs debug}, env: env
  appbundle "berkshelf", lockdir: project_dir, gem: "berkshelf", without: %w{changelog docs debug development}, env: env

  # Note - 'chef-apply' gem provides 'chef-run', not 'chef-apply' which ships with chef-bin...
  %w{chef-bin chef-apply chef-vault ohai opscode-pushy-client cookstyle}.each do |gem|
    appbundle gem, lockdir: project_dir, gem: gem, without: %w{changelog}, env: env
  end

  # Clear git-checked-out gems (most of this cleanup has been moved into the chef-cleanup omnibus-software definition,
  # but chef-client still needs git-checked-out gems)
  block "Delete bundler git installs" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp
    remove_directory "#{gemdir}/bundler"
  end
end
