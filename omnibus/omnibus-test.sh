#!/bin/bash
set -ueo pipefail

is_darwin()
{
  uname -a | grep "^Darwin" 2>&1 >/dev/null
}

# Ensure user variables are set in git config
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

export CHEF_LICENSE="accept-no-persist"
export HAB_LICENSE="accept-no-persist"

echo "--- Ensure the 'chef' cli works (chef env)"
chef env

echo "--- Ensure the 'chef report' subcommand cli works (chef report help)"
chef report help

echo "--- Ensure that 'hab' cli is available"
hab help

echo "--- Ensure that 'chef-automate-collect' cli is available"
chef exec chef-automate-collect -h

# Verify that the chef-workstation-app was installed (MacOS only)
if is_darwin; then
  echo "--- Verifying that chef-workstation-app exist in /Applications directory"
  test -d "/Applications/Chef Workstation App.app"
fi

echo "--- Run Workstation verification suite"
/opt/chef-workstation/embedded/bin/ruby omnibus/verification/run.rb
