#
# Super simple temporary chef-dk software definition. This enables us to
# install *only* the chef-dk code without any of the extra dependencies
# (Test Kitchen, Berkshelf, etc.). In the future when we merge these projects
# this will go away.
#

name "chef-dk"
default_version "master"
source git: "https://github.com/chef/chef-dk.git"

license :project_license

dependency "rubygems"
dependency "bundler"
dependency "ruby"

# For nokogiri
dependency "libxml2"
dependency "libxslt"
dependency "liblzma"
dependency "zlib"
dependency "libarchive"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  bundle "install --without development omnibus_package provisioning", env: env
  gem "build chef-dk.gemspec", env: env
  gem "install chef-dk*.gem" \
      " --no-ri --no-rdoc" \
      " --force" \
      " --verbose --without development", env: env
end
