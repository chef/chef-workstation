#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses Expeditor to manage the bundled version of chef-analyze.
# Currently we always want to include the latest version of chef-analyze inside
# Workstation, so this script takes that version and uses sed to insert it into the
# omnibus_overrides.rb file. Then it commits that change and opens a pull request for
# review and merge.
############################################################################

set -evx

version=$(get_github_file "$EXPEDITOR_REPO" main VERSION)
branch="expeditor/chef-analyze${version}"
git checkout -b "$branch"

sed -i -r "s/override \"chef-analyze\",\s+version: \"[^\"]+\"/override \"chef-analyze\", version: \"${version}\"/" omnibus_overrides.rb

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump chef-analyze CLI to $version" --message "This pull request was triggered automatically via Expeditor when chef-analyze $version was merged to main." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
