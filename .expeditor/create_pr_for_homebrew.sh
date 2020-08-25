#!/bin/bash

set -ex
FORK_OWNER="chef"
UPSTREAM_OWNER="Homebrew"
REPO_NAME="homebrew-cask"
BRANCH="${EXPEDITOR_PRODUCT_KEY}-${EXPEDITOR_VERSION}"
URL="https://omnitruck.chef.io/stable/$EXPEDITOR_PRODUCT_KEY/metadata?p=mac_os_x&pv=10.14&m=x86_64&v=$EXPEDITOR_VERSION"
SHA=""

echo "--- Getting $FORK_OWNER/$REPO_NAME repository and updating latest from upstream $UPSTREAM_OWNER/$REPO_NAME"
git clone git@github.com:/$FORK_OWNER/$REPO_NAME
cd $REPO_NAME

git config user.email "expeditor@chef.io"
git config user.name "Chef Expeditor"

git remote add upstream "git@github.com:/$UPSTREAM_OWNER/$REPO_NAME"

git checkout master
git fetch --all

# Reset the chef/homebrew-cask fork to the upstream so we are always
# making a PR off their master
git reset --hard upstream/master
git push origin master

git checkout -b "$BRANCH"

function get_sha() {
  curl -Ss "$URL" | sed -n 's/sha256\s*\(\S*\)/\1/p' | awk '{$1=$1;print}'
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

echo "Updating Casks/chef-workstation.rb version: $EXPEDITOR_VERSION sha: $SHA"

sed -i '' "s/version '.*'/version '$EXPEDITOR_VERSION'/g" Casks/chef-workstation.rb
sed -i '' "s/sha256 '.*'/sha256 '$SHA'/g" Casks/chef-workstation.rb

echo "--- Debug: git diff of patched file follows"
git diff

echo "--- Fetching latest homebrew"
git clone git@github.com:Homebrew/brew.git

echo "--- Verifying Cask"

./brew/bin/brew cask style --fix ./Casks/chef-workstation.rb
./brew/bin/brew cask audit --download ./Casks/chef-workstation.rb

rm -rf brew # clean up our brew checkout

echo "-- Committing change"

# This conforms with the PR template used by homebrew-cask
# https://github.com/Homebrew/homebrew-cask/.github/PULL_REQUEST_TEMPLATE.md
TITLE="Bump $EXPEDITOR_PRODUCT_KEY to $EXPEDITOR_VERSION"
BODY=$(cat <<EOB
After making all changes to the cask:
- [x] \`brew cask audit --download Casks/chef-workstation.rb\` is error-free.
- [x] \`brew cask style --fix Casks/chef-workstation.rb\` reports no offenses.
- [x] The commit message includes the cask’s name and version.
- [x] The submission is for stable version.
EOB
)

# the json form of this needs to not have unescaped newlines.
PR_BODY="After making all changes to the cask:\\n - [x] \`brew cask audit --download Casks/chef-workstation.rb\` is error-free.\\n - [x] \`brew cask style --fix Casks/chef-workstation.rb\` reports no offenses.\\n - [x] The commit message includes the cask’s name and version.\\n - [x] The submission is for stable version.\\n"

COMMIT_BODY=$(cat <<EOB
$TITLE

$BODY
EOB
)

git add ./Casks/chef-workstation.rb
git status
git commit --message "$COMMIT_BODY"

echo "--- Opening PR"

git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${FORK_OWNER}/${REPO_NAME}.git" "$BRANCH" --force;
result=$(curl --silent --header "Authorization: token $CHEF_CI_GITHUB_AUTH_TOKEN" \
  --data-binary "{\"title\":\"$TITLE\",\"head\":\"chef:$BRANCH\",\"base\":\"master\",\"maintainer_can_modify\":false,\"body\":\"$PR_BODY\"}" \
  -XPOST "https://api.github.com/repos/${UPSTREAM_OWNER}/${REPO_NAME}/pulls" \
  --write-out "Response:%{http_code}")

# NOTE: If the PR creation fails due to errors around not being able to update
# github actions from an app/bot user, you will need to correct this by manually
# syncing up the fork chef/homebrew-cask to the upstream homebrew/homebrew-cask; most likely
# upstream has changed something related to their github actions configuration, and
# github disallows the bots from updating those files.

# Fail the run if 201 (created) response not received.
echo "$result" | grep "Response:201"

