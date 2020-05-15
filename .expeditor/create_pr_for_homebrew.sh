#!/bin/bash

# This bumps the version in the ENV var 'EXPEDITOR_VERSION' on the project specified
# It fetches the sha256 via omnitruck api

set -ex
echo "--- Getting chef/homebrew-cask repository and updating latest from upstream Homebrew/homebrew-casks"
git clone git@github.com:/chef/homebrew-cask-autotesting homebrew-cask
#git clone git@github.com:/chef/homebrew-cask
cd homebrew-cask
git config user.email "expeditor@chef.io"
git config user.name "Chef Expeditor"

#git remote add upstream git@github.com:/Homebrew/homebrew-cask
git remote add upstream git@github.com:/marcparadise/homebrew-cask-autotesting
git fetch --all
# Reset the chef/homebrew-cask fork to the upstream so we are always
# making a PR off their master
git reset --hard upstream/master
git push origin master

branch="chef-software/${EXPEDITOR_PRODUCT_KEY}-${EXPEDITOR_VERSION}"
git checkout master
git checkout -b "$branch"

URL="https://omnitruck.chef.io/stable/$EXPEDITOR_PRODUCT_KEY/metadata?p=mac_os_x&pv=10.14&m=x86_64&v=$EXPEDITOR_VERSION"
SHA=""

function get_sha() {
  curl -Ssv "$URL" | sed -n 's/sha256\s*\(\S*\)/\1/p'
}

delay=20 # seconds
tries=60 # retry for up to 20 minutes

echo "--- Fetching package information for $EXPEDITOR_PRODUCT_KEY @ $EXPEDITOR_VERSION - $tries attempts remain"
for (( i=1; i<=tries; i+=1 )); do
  SHA=$(get_sha)
  if [ -z "$SHA" ]; then
    if [ "$i" -eq "$tries" ]; then
      echo "Omnitruck did not return a SHA256 value for the $EXPEDITOR_PRODUCT_KEY $EXPEDITOR_VERSION!"
      echo "Tried $tries times to fetch from $URL"
      exit 1
    else
      sleep $delay
    fi
  else
    echo "Found Omnitruck artifact for $EXPEDITOR_PRODUCT_KEY $EXPEDITOR_VERSION"
    break
  fi
done

echo "Updating Cask $EXPEDITOR_PRODUCT_KEY"
echo "Updating version to $EXPEDITOR_VERSION"
sed -i -r "s/(version\s*'.+')/version '$EXPEDITOR_VERSION'/g" Casks/chef-workstation.rb
echo "Updating sha to $SHA"

sed -i -r "s/(sha256\s*'.+')/sha256 '$SHA'/g" Casks/chef-workstation.rb

echo "--- Debug: git diff follows"
git diff

echo "git status follows:"
git status

echo "-- Verifying Cask"
echo Running style fixes "brew cask style --fix"
brew cask style --fix ./Casks/chef-workstation.rb
echo Verifying with "brew cask audit --download"
brew cask audit --download ./Casks/chef-workstation.rb

# This conforms with the PR template used by homebrew-cask
# https://github.com/Homebrew/homebrew-cask/.github/PULL_REQUEST_TEMPLATE.md
BODY=$(cat <<EOB
Bump $EXPEDITOR_PRODUCT_KEY to $EXPEDITOR_VERSION

After making all changes to the cask:

- [x] \`brew cask audit --download {{cask_file}}\` is error-free.
- [x] \`brew cask style --fix {{cask_file}}\` reports no offenses.
- [x] The commit message includes the cask’s name and version.
- [x] The submission is for stable version.

EOB
)

echo "-- Committing change and opening PR"
git status

git add ./Casks/chef-workstation.rb
git commit --message "$BODY"

open_pull_request
