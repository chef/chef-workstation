set -eou pipefail

branch="expeditor/update_docs_lints"
git checkout -b "$branch"

# Wait 5 minutes
sleep 300

# get the file from chef-web-docs

get_github_file chef/chef-web-docs main .markdownlint.yaml > .markdownlint.yaml
get_github_file chef/chef-web-docs main .vale.ini > .vale.ini
get_github_file chef/chef-web-docs main cspell.json > cspell.json

# add changes
git add .

# give a friendly message for the commit and make sure it's noted for any future
# audit of our codebase that no DCO sign-off is needed for this sort of PR since
# it contains no intellectual property

dco_safe_git_commit "Update $EXPEDITOR_REPO docs lints."

# open pull request

open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at
# the end of this script will get committed to main.
git checkout -
git branch -D "$branch"
