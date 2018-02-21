#!/bin/bash
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

pushd ./components/chef-workstation
  sed -i -r "s/^(\s*)VERSION = \".+\"/\1VERSION = \"$(cat ../../VERSION)\"/" lib/chef-workstation/version.rb
  # Ensure our Gemfile.lock reflects the new version
  bundle update chef-workstation
popd
