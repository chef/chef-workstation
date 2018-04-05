#!/bin/sh
#
# After a PR merge, Chef Expeditor will bump the PATCH version in the VERSION file.
# It then executes this file to update any other files/components with that new version.
#

set -evx

sed -i -r "s/VERSION = \".*\"/VERSION = \"$(cat VERSION)\"/"  components/chef-workstation/lib/chef-workstation/version.rb

# Ensure our Gemfile.lock reflects the new version
pushd components/chef-workstation
bundle update chef-workstation
popd

# run readme update script.
# TODO: Remove this when expeditor issue requiring mixlib install definition
# is fixed. This check prevents us changing our config file.
.expeditor/update_readme_download_urls.sh
