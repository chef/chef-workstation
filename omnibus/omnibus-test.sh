#!/bin/bash
set -ueo pipefail

channel="${CHANNEL:-unstable}"
product="${PRODUCT:-chef-workstation}"
version="${VERSION:-latest}"

echo "--- Installing $channel $product $version"
package_file="$(install-omnibus-product -c "$channel" -P "$product" -v "$version" | tail -n 1)"

echo "--- Verifying omnibus package is signed"
check-omnibus-package-signed "$package_file"

echo "--- Verifying ownership of package files"

export INSTALL_DIR=/opt/chef-workstation
NONROOT_FILES="$(find "$INSTALL_DIR" ! -uid 0 -print)"
if [[ "$NONROOT_FILES" == "" ]]; then
  echo "Packages files are owned by root.  Continuing verification."
else
  echo "Exiting with an error because the following files are not owned by root:"
  echo "$NONROOT_FILES"
  exit 1
fi

echo "--- Running verification for $channel $product $version"

# chef version ensures our bin ends up on path and the basic ruby env is working.
chef-run --version

# Ensure our ChefDK works
chef env
