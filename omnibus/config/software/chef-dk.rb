name "chef-dk"
default_version "master"

license :project_license
source git: "git://github.com/chef/chef-dk.git"

# For nokogiri
dependency "libxml2"
dependency "libxslt"
dependency "liblzma"
dependency "zlib"
dependency "libarchive"

#
# NOTE: NO GEM DEPENDENCIES
#
# we do not add dependencies here on omnibus-software definitions that install gems.
#
# all of the gems for chef-dk must be installed in the mega bundle install below.
#
# doing bundle install / rake install in dependent software definitions causes gemsets
# to get solved without some of the chef-dk constraints, which results in multiple different
# versions of gems in the omnibus bundle.
#
# for gems that depend on c-libs, we include the c-libraries directly here.
#

# For berkshelf
dependency "libarchive"

# For opscode-pushy-client
dependency "libzmq"

# ruby and bundler and friends
dependency "ruby"
dependency "rubygems"
dependency "bundler" # technically a gem, but we gotta solve the chicken-egg problem here

# for train
dependency "google-protobuf"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Patch cli.rb show_version function and add token we can later use to swap in the build_version.
  patch source: "cli.patch", target: "./lib/chef-dk/cli.rb"

  # Change the license to be accepted for Chef Workstation instead of ChefDK
  patch source: "base.patch", target: "./lib/chef-dk/command/base.rb"

  # Cross platform way to sed. Need to cleanup the backup fail.
  command("sed -i.bak 's/\\$CHEF_WS_VERSION\\$/#{project.build_version}/' #{project_dir}/lib/chef-dk/cli.rb", env: env)
  command("rm #{project_dir}/lib/chef-dk/cli.rb.bak")

  excluded_groups = %w{server docgen maintenance pry travis integration ci}

  # install the whole bundle first
  bundle "install --without #{excluded_groups.join(' ')}", env: env

  gem "build chef-dk.gemspec", env: env

  gem "install chef*.gem --no-document --verbose", env: env

  env["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"

  appbundle "chef", lockdir: project_dir, gem: "chef", without: %w{docgen chefstyle}, env: env

  appbundle "foodcritic", lockdir: project_dir, gem: "foodcritic", without: %w{development}, env: env
  appbundle "test-kitchen", lockdir: project_dir, gem: "test-kitchen", without: %w{changelog debug docs}, env: env
  appbundle "inspec", lockdir: project_dir, gem: "inspec-bin", without: %w{deploy tools maintenance integration}, env: env

  %w{chef-bin chef-dk chef-apply chef-vault ohai opscode-pushy-client cookstyle dco berkshelf}.each do |gem|
    appbundle gem, lockdir: project_dir, gem: gem, without: %w{changelog}, env: env
  end

  # Clear git-checked-out gems (most of this cleanup has been moved into the chef-cleanup omnibus-software definition,
  # but chef-client still needs git-checked-out gems)
  block "Delete bundler git installs" do
    gemdir = shellout!("#{install_dir}/embedded/bin/gem environment gemdir", env: env).stdout.chomp
    remove_directory "#{gemdir}/bundler"
  end
end
