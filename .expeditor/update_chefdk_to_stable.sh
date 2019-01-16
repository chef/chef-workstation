#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses Expeditor to manage the bundled version of the ChefDK.
# Currently we always want to include the stable version of ChefDK inside Workstation,
# so this script takes that version and uses sed to insert it into the omnibus_overrides.rb
# file. Then it commits that change and opens a pull request for review and merge.
############################################################################

set -evx

branch="expeditor/chef_dk_${VERSION}"
git checkout -b "$branch"

sed -i -r "s/override :\"chef-dk\",\s+version: \"v[^\"]+\"/override :\"chef-dk\", version: \"v${VERSION}\"/" omnibus_overrides.rb

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump ChefDK to $VERSION" --message "This pull request was triggered automatically via Expeditor when ChefDK $VERSION was promoted to stable." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request

# Get back to master and cleanup the leftovers - any changed files left over at the end of this script will get committed to master.
git checkout -
git branch -D "$branch"
