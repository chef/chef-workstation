#!/bin/bash

set -ex
FORK_OWNER="chef"
UPSTREAM_OWNER="Homebrew"
REPO_NAME="homebrew-cask"
BRANCH="${EXPEDITOR_PRODUCT_KEY}-${EXPEDITOR_VERSION}"
URL="https://omnitruck.chef.io/stable/$EXPEDITOR_PRODUCT_KEY/metadata?p=mac_os_x&pv=11&m=x86_64&v=$EXPEDITOR_VERSION"
SHA=""

echo "Forking the repo"
brew tap --force homebrew/cask

cd "$(brew --repository homebrew/cask)"

echo "Setting up the forked repo"
git config user.email "expeditor@chef.io"
git config user.name "Chef Expeditor"

git fetch --all
git checkout -b "$BRANCH" #upstream/master

# This conforms with the PR template used by homebrew-cask
# https://github.com/Homebrew/homebrew-cask/.github/PULL_REQUEST_TEMPLATE.md
TITLE="Bump $EXPEDITOR_PRODUCT_KEY to $EXPEDITOR_VERSION"
BODY=$(cat <<EOB
After making any changes to a cask, existing or new, verify:

- [x] The submission is for [a stable version](https://docs.brew.sh/Acceptable-Casks#stable-versions).
- [x] \`brew audit --cask --online chef-workstation\` is error-free.
- [x] \`brew style --fix chef-workstation\` reports no offenses.

Additionally, **if adding a new cask**:

- [ ] Named the cask according to the [token reference](https://docs.brew.sh/Cask-Cookbook#token-reference).
- [ ] Checked the cask was not [already refused](https://github.com/Homebrew/homebrew-cask/search?q=is%3Aclosed&type=Issues).
- [ ] Checked the cask is submitted to [the correct repo](https://docs.brew.sh/Acceptable-Casks#finding-a-home-for-your-cask).
- [ ] \`brew audit --cask --new <cask>\` worked successfully.
- [ ] \`brew install --cask <cask>\` worked successfully.
- [ ] \`brew uninstall --cask <cask>\` worked successfully.

EOB
)

COMMIT_BODY=$(cat <<EOB
$TITLE

$BODY
EOB
)

function get_sha() {
  curl -Ss "$URL" | sed -n 's/sha256\s*\(\S*\)/\1/p' | awk '{$1=$1;print}'
}

delay=60 # seconds
tries=60 # retry for up to 1 hour

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

echo "Running the brew bump-cask-pr task to bump the version...."

brew bump-cask-pr $EXPEDITOR_PRODUCT_KEY --version $EXPEDITOR_VERSION \
     --message "$COMMIT_BODY" \
     --force -vvv
