#!/bin/bash
set -ueo pipefail

is_darwin()
{
  uname -a | grep "^Darwin" 2>&1 >/dev/null
}

# TODO: Need to remove the lin_aarch64 function once the hab package is available in linux aarch64 platform
lin_aarch="0"
lin_aarch64()
{
  unamestr=$(uname)
  unamearchstr=$(uname -m)
  if [[ "$unamestr" == 'Linux' ]]; then
	  if [[ "$unamearchstr" == 'aarch64' ]]; then
      lin_aarch="1"
	    uname -m | grep "aarch64" 2>&1 >/dev/null
    fi
  fi
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

# TODO: Need to remove the lin_aarch64 function call and the condition check once the hab package is available in linux aarch64 platform.
lin_aarch64

if [ "$lin_aarch" = "0" ]; then
  echo "--- Ensure that 'hab' cli is available"
  hab help
fi

# We are commenting this code on a purpose.
# We have to stop building chef-automate-collect in chef workstation temporarily.
# Please refer the issue: https://github.com/chef/chef-workstation/issues/2286
 
# echo "--- Ensure that 'chef-automate-collect' cli is available"
# chef exec chef-automate-collect -h

# Verify that the chef-workstation-app was installed (MacOS only)
if is_darwin; then
  echo "--- Verifying that chef-workstation-app exist in /Applications directory"
  test -d "/Applications/Chef Workstation App.app"
fi

echo "--- Run Workstation verification suite"
/opt/chef-workstation/embedded/bin/ruby omnibus/verification/run.rb
