#!/bin/bash
set -ueo pipefail

channel="${CHANNEL:-unstable}"
product="${PRODUCT:-chef-workstation}"
version="${VERSION:-latest}"

is_darwin()
{
  uname -a | grep "^Darwin" 2>&1 >/dev/null
}

echo "--- Installing $channel $product $version"
package_file="$(/opt/omnibus-toolchain/bin/install-omnibus-product -c "$channel" -P "$product" -v "$version" | tail -n 1)"

echo "--- Verifying omnibus package is signed"
/opt/omnibus-toolchain/bin/check-omnibus-package-signed "$package_file"

sudo rm -f "$package_file"

echo "--- Verifying ownership of package files"

export INSTALL_DIR=/opt/chef-workstation
NONROOT_FILES="$(find "$INSTALL_DIR" ! -user 0 -print)"
if [[ "$NONROOT_FILES" == "" ]]; then
  echo "Packages files are owned by root.  Continuing verification."
else
  echo "Exiting with an error because the following files are not owned by root:"
  echo "$NONROOT_FILES"
  exit 1
fi

echo "--- Running verification for $channel $product $version"

# Ensure user variables are set in git config
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

export CHEF_LICENSE="accept-no-persist"
export HAB_LICENSE="accept-no-persist"

echo "--- Ensure the 'chef' cli works (chef env)"
chef env

echo "--- Ensure the 'chef report' subcommand cli works (chef report help)"
chef report help

echo "--- Ensure that 'hab' cli is avaliable"
hab help


# Verify that the chef-workstation-app was installed (MacOS only)
if is_darwin; then
  echo "--- Verifying that chef-workstation-app exist in /Applications directory"
  test -d "/Applications/Chef Workstation App.app"
fi

echo "--- Run Workstation verification suite"
/opt/chef-workstation/embedded/bin/ruby omnibus/verification/run.rb
