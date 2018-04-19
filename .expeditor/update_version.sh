#!/bin/bash
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

sed -i -r "s/VERSION = \".*\"/VERSION = \"$(cat VERSION)\"/"  components/chef-workstation/lib/chef-workstation/version.rb

# Temporary workound while ChefDK has older ruby version
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
gem install bundler

# Ensure our Gemfile.lock reflects the new version
cd components/chef-workstation
bundle update chef-workstation
