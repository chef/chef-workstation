#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses Expeditor to manage the bundled version of the
# Chef Workstation App. Currently we always want to include the latest version
# of Chef Workstation App inside Workstation, so this script takes that version
# and uses sed to insert it into the omnibus_overrides.rb file. Then it commits
# that change and opens a pull request for review and merge.
############################################################################

set -evx

ARTIFACTORY_TOKEN=$(vault kv get -field token account/static/artifactory/buildkite)

export JFROG_CLI_LOG_LEVEL="ERROR"
export JFROG_CLI_OFFER_CONFIG=false

default_version=$(get_github_file chef/chef-workstation-app ${EXPEDITOR_BUILD_BRANCH:-main} VERSION)
version="${VERSION:-$default_version}"
branch="expeditor/chef_workstation_app_${version}"
git checkout -b "$branch"

linux_checksum=$(jfrog rt s --apikey "$ARTIFACTORY_TOKEN" --url=https://artifactory-internal.ps.chef.co/artifactory "files-unstable-local/chef-workstation-app/${version}/chef-workstation-app-${version}-linux-x64.zip" | jq -r '.[] | .sha1')
windows_checksum=$(jfrog rt s --apikey "$ARTIFACTORY_TOKEN" --url=https://artifactory-internal.ps.chef.co/artifactory "files-unstable-local/chef-workstation-app/${version}/chef-workstation-app-${version}-win32-x64.zip" | jq -r '.[] | .sha1')

sed -i -r "s/^default_version \".+\"/default_version \"${version}\"/" omnibus/config/software/chef-workstation-app.rb
sed -i -r "s/^source sha1\: \".+\" if linux\?$/source sha1: \"$linux_checksum\" if linux?/" omnibus/config/software/chef-workstation-app.rb
sed -i -r "s/^source sha1\: \".+\" if windows\?$/source sha1: \"$windows_checksum\" if windows?/" omnibus/config/software/chef-workstation-app.rb

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump Chef Workstation App to $version" --message "This pull request was triggered automatically via Expeditor when Chef Workstation App $version was merged." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
