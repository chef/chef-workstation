#!/bin/sh
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

sed -i -r "s/VERSION = '.*'/VERSION = '$(cat VERSION)'/"  components/chef-workstation/lib/chef-workstation/version.rb

# Update the version inside Gemfile.lock
cd components/chef-workstation; bundle update chef-workstation

# Once Expeditor finshes executing this script, it will commit the changes and push
# the commit as a new tag corresponding to the value in the VERSION file.
