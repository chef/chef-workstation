set -eou pipefail

branch="expeditor/update_docs_lints"
git checkout -b "$branch"

# Wait
sleep 60

# submit pull request to chef/releng-services
get_github_file ${EXPEDITOR_REPO} main .markdownlint.yaml
git add .

# give a friendly message for the commit and make sure it's noted for any future
# audit of our codebase that no DCO sign-off is needed for this sort of PR since
#it contains no intellectual property

dco_safe_git_commit "Update $EXPEDITOR_REPO docs lints."

open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at
# the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
