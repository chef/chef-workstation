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

version=$(get_github_file $EXPEDITOR_REPO master VERSION)
branch="expeditor/chef_workstation_app_${version}"
git checkout -b "$branch"

sed -i -r "s/override \"chef-workstation-app\",\s+version: \"v[^\"]+\"/override \"chef-workstation-app\", version: \"v${version}\"/" omnibus_overrides.rb

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump Chef Workstation App to $version" --message "This pull request was triggered automatically via Expeditor when Chef Workstation App $version was merged." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request

# Get back to master and cleanup the leftovers - any changed files left over at the end of this script will get committed to master.
git checkout -
git branch -D "$branch"
