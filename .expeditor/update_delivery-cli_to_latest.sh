#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses Expeditor to manage the bundled version of the Delivery CLI.
# Currently we always want to include the latest version of Delivery CLI inside
# Workstation, so this script takes that version and uses sed to insert it into the
# omnibus_overrides.rb file. Then it commits that change and opens a pull request for
# review and merge.
############################################################################

set -evx

version=$(get_github_file $EXPEDITOR_REPO master VERSION)
branch="expeditor/delivery-cli_${version}"
git checkout -b "$branch"

sed -i -r "s/override \"delivery-cli\",\s+version: \"[^\"]+\"/override \"delivery-cli\", version: \"${version}\"/" omnibus_overrides.rb

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump Delivery CLI to $version" --message "This pull request was triggered automatically via Expeditor when Delivery CLI $version was merged to master." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request

# Get back to master and cleanup the leftovers - any changed files left over at the end of this script will get committed to master.
git checkout -
git branch -D "$branch"
