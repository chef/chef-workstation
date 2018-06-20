#!/bin/bash
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

sed -i -r "s/VERSION = \".*\"/VERSION = \"$(cat VERSION)\"/"  components/chef-run/lib/chef-run/version.rb

# Ensure our Gemfile.lock reflects the new version
cd components/chef-run
bundle update chef-run
cd ../..
