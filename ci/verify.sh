# This script is used in the jenkins part of our pipeline to verify our package
# is working correctly after install.
set -e

# chef version ensures our bin ends up on path and the basic ruby env is working.
chef-run --version

# Ensure our ChefDK works
chef env
