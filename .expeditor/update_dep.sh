#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses a workflow tool called Expeditor to manage version bumps,
# changelogs and releases. When a dependency of chef is released, expeditor is
# triggered against this repository to run this script. It bumps our gem lock files
# and opens a PR. That way humans can do hard work and bots can open gem bump PRs.
############################################################################

set -evx

GEM_NAME="${EXPEDITOR_GEM_NAME:-${EXPEDITOR_PRODUCT_KEY:?Could not find gem name}}"

function new_gem_included() {
  git diff | grep -E '^\+' | grep "${GEM_NAME} (${EXPEDITOR_VERSION})"
}

branch="expeditor/${GEM_NAME}_${EXPEDITOR_VERSION}"
git branch -D "$branch" || true
git checkout -b "$branch"

pushd components/gems
tries=12
for (( i=1; i<=$tries; i+=1 )); do
  bundle lock --update
  new_gem_included && break || sleep 20
  if [ $i -eq $tries ]; then
    echo "Searching for '${GEM_NAME} (${EXPEDITOR_VERSION})' ${i} times and did not find it"
    exit 1
  else
    echo "Searched ${i} times for '${GEM_NAME} (${EXPEDITOR_VERSION})'"
  fi
done
popd

git add .

# give a friendly message for the commit and make sure it's noted for any future audit of our codebase that no
# DCO sign-off is needed for this sort of PR since it contains no intellectual property
git commit --message "Bump $GEM_NAME to $EXPEDITOR_VERSION" --message "This pull request was triggered automatically via Expeditor when $GEM_NAME $EXPEDITOR_VERSION was promoted to Rubygems." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."

open_pull_request "$EXPEDITOR_BRANCH"

# Get back to main and cleanup the leftovers - any changed files left over at the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
