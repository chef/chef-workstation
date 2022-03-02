set -eou pipefail

branch="expeditor/update_docs_lints_${EXPEDITOR_REPO}_${EXPEDITOR_DATE}"
repo=${EXPEDITOR_REPO##*/}
git checkout -b "$branch"

# Wait
sleep 60

# submit pull request to chef/releng-services

git add .

# give a friendly message for the commit and make sure it's noted for any future
# audit of our codebase that no DCO sign-off is needed for this sort of PR since
#it contains no intellectual property

dco_safe_git_commit "Updating ${repo} docs lints to ${EXPEDITOR_DATE}."

open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at
# the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
