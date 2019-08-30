#!/bin/bash
set -ueo pipefail

# Ensure user variables are set in git config
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

channel="${CHANNEL:-unstable}"
product="${PRODUCT:-chef-workstation}"
version="${VERSION:-latest}"
# Still allow the test to be run locally by skipping package install if we're not in the Ci env.
if [ -f /opt/omnibus-toolchain/bin/install-omnibus-product  ]; then

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

fi

echo "--- Running verification for $channel $product $version"
# These environment vars were set by default
export CHEF_LICENSE="accept-no-persist"
export PATH=/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH
# Ensure no errors when running `chef` out of Workstation


export_gem_location_for() {

  gem_which=$(gem which "$1")
  gem_dir=$(dirname "$gem_which")/..
  gem_location=$(realpath "$gem_dir")
  export gem_location
}
export_temp_dir() {
  temp_dir="$(mktemp -d -t)"
  export temp_dir
}

cleanup_temp_dir() {
  if [ -v $temp_dir ]; then
    rm -rf "$temp_dir"
    unset temp_dir
  fi
}


# Ensure our temporary directory is deleted
# given function cleanup(), then we can:
# Note: the interrupt is handled in a running ruby app as a failure,
#       and is not picked up by the trap
trap cleanup_temp_dir EXIT
trap 'echo "Interrupt received, stopping"; cleanup_temp_dir; exit 127' INT TERM

# Load the WS gem environment so that we can reach the gems we care about
# Previously these actions would run from within a `chef` command,
# where the ruby environment is already set up
echo "Preparing environment"
eval "$(chef shell-init bash)"

echo 'Verifying package installation'

echo "berks "
berks -v
echo "chef "
chef -v
echo "chef-client"
chef-client -v
echo "chef-solo"
chef-solo -v
echo "delivery-cli"
delivery -V

# In `knife`, `knife -v` follows a different code path that skips
# command/plugin loading; `knife -h` loads commands and plugins, but
# it exits with code 1, which is the same as a load error. Running
# `knife exec` forces command loading to happen and this command
# exits 0, which runs most of the code.
#
# See also: https://github.com/chef/chef-dk/issues/227
echo "knife with commands and plugins loaded"
knife exec -E true

echo "kitchen"
export_temp_dir
pushd "$temp_dir"
  # Kitchen makes a .kitchen even for -v
  kitchen -v
popd
cleanup_temp_dir

echo "ohai"
ohai -v
echo "foodcritic"
foodcritic -V
echo "inspec"
inspec version


echo "Verifying berkshelf"
export_gem_location_for "berkshelf"
pushd "$gem_location"
  bundle install --quiet --with=development

  echo "Running unit test for berkshelf"
  # TODO Berkshelf has an undeclared test dep on webmock,
  #      we'll need to update the Gemfile to get these tests to run:
  #bundle exec /opt/chef-workstation/embedded/bin/rspec --color --format progress spec/unit --tag ~graphiz

  echo "Running smoke test for berkshelf"
  export_temp_dir
  pushd "$temp_dir"
    echo "" > Berksfile
    berks install
  popd
  cleanup_temp_dir
popd

echo "Verifying test-kitchen"
export_gem_location_for "kitchen"
pushd "$gem_location"
  echo "Configuring test-kitchen for test"
  echo "Current dir: $(pwd)"
  echo "Gem location: $gem_location"
  bundle install --quiet --with=development

  echo "Running unit tests for test-kitchen"
  bundle exec rake unit

  echo "Running integration tests for test-kitchen"
  bundle exec rake features

  echo "Running smoke test for test-kitchen"
  export_temp_dir
  pushd "$temp_dir"

  # Note that now we're directly running our packaged kitchen, and not via the bundle isntall above.
  kitchen init --create-gemfile
  popd

  cleanup_temp_dir
popd

echo "Verifying policifile provisioning"
  export_temp_dir
  pushd "$temp_dir"
    echo "Running smoke test for tk-policyfile-provision via kitchen list"
    cat > kitchen.yml <<KITCHEN_YML
---
driver:
  name: dummy
  network:
    - ["forwarded_port", {guest: 80, host: 8080}]

provisioner:
  name: policyfile_zero
  require_chef_omnibus: 12.3.0

platforms:
  - name: ubuntu-14.04

suites:
  - name: default
    run_list:
      - recipe[aar::default]
    attributes:
KITCHEN_YML

    kitchen list
  popd
  cleanup_temp_dir

echo "Verifying Chef Infra"
  # chef infra  via 'chef' gem
  export_gem_location_for "chef"
  pushd "$gem_location"
    echo "Configuring Chef Infra for validation"
    bundle install --quiet

    echo "Running unit tests for Chef Infra"
    bundle exec rspec -fp -t "~volatile_from_verify" "spec/unit"

    echo "Running integration tests for Chef Infra"
    bundle exec rspec -fp "spec/integration" "spec/functional"

    echo "Running smoke tests for Chef Infra"
    export_temp_dir
    pushd "$temp_dir"
      touch apply.rb
      chef-apply apply.rb
    popd
    cleanup_temp_dir
  popd

echo "Verifying Chef CLI"
  export_gem_location_for "chef-cli"
  pushd "$gem_location"
    echo "Configuring Chef CLI for validation"
    bundle install --quiet
    echo "Running unit tests for Chef CLI"
    bundle exec rspec
    echo "Running smoke tests for Chef CLI"
    export_temp_dir
    pushd "$temp_dir"
      chef generate cookbook example
      echo "Verifying tests pass for generated cookbook"
      pushd example
         rspec
      popd
    popd
    cleanup_temp_dir
  popd

echo "Verifying chef-run"
  export_gem_location_for "chef_apply"
  pushd "$gem_location"
    echo "Configuring chef-run for validation"
    bundle install --quiet
    echo "Running unit test for chef-run"
    bundle exec rspec
    export_temp_dir
    pushd "$temp_dir"
      echo "Running smoke test for chef-run"
      CHEF_TELEMETRY_OPT_OUT=true chef-run -v
    popd
    cleanup_temp_dir
  popd

export_gem_location_for "chefspec"
pushd "$gem_location"
  bundle install --quiet
  echo "Running unit tests for ChefSpec"
  bundle exec rspec
  echo "Running smoke tests for ChefSpec: verify library loading"
  export_temp_dir
  pushd "$temp_dir"
    # Ensures that chefspec and berkshelf resolve without conflicts
    # from the chef-workstation packaged gems
    mkdir spec
    cat > spec/spec_helper.rb <<SPEC_HELPER_RB
      require 'chefspec'
      require 'chefspec/berkshelf'
      require 'chefspec/cacher'

      RSpec.configure do |config|
          config.expect_with(:rspec) { |c| c.syntax = :expect }
      end
SPEC_HELPER_RB
    echo "require 'spec_helper'" > spec/foo_spec.rb
    touch Berksfile
    rspec
  popd
  cleanup_temp_dir
popd


echo "Running smoke test for fauxhai"
  gem list fauxhai

echo "Running smoke test for kitchen-vagrant"
  # (Original comment: The build is not passing in travis, so no tests)
  # TODO time to revisit that?
  gem list kitchen-vagrant

echo "Running smoke test for openssl"
  export_temp_dir
  pushd "$temp_dir"
    cat > openssl.rb <<SSL_RB
        require "net/http" unless defined?(Net::HTTP)
        uris = %w{https://www.google.com https://chef.io/ https://ec2.amazonaws.com}
        uris.each do |uri|
          # uri = URI(uri)
          puts "Fetching #{uri} for SSL check"
          # Net::HTTP.get uri
          uri = URI(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.get(uri.request_uri)
        end
SSL_RB
    ruby openssl.rb
  popd
  cleanup_temp_dir



echo "running smoke test for Chef Inspec"
  export_temp_dir
  pushd "$temp_dir"
    cat > some_spec.rb <<SOME_SPEC_RB
      rule '01' do
        impact 0.7
        title 'Some Test'
        desc 'Make sure inspec is installed and loading correct'
        describe 1 do
          it { should eq(1) }
        end
      end
SOME_SPEC_RB
    # TODO - should we be just running this directly and not via chef exec?
    chef exec inspec exec .
  popd
  cleanup_temp_dir

echo "running smoke test for delivery-cli"
  # comment preserved from chef-cli/commands/verify.rb
  # We'll want to come back and revisit getting unit tests added -
  # currently running the tests depends on cargo , which is not included
  # in our package.
  export_temp_dir
  pushd "$temp_dir"
    delivery setup --user=shipit --server=delivery.shipit.io --ent=chef --org=squirrels
  popd
  cleanup_temp_dir

echo "verifying git"
  if [ "$(uname)" == "Darwin" ]; then
    native_bin_dir="/usr/local/bin"
  else
    native_bin_dir="/usr/bin"
  fi

  if [ -f "/opt/chef-workstation/bin/git" ]; then
    echo "ERROR: Git is installed in /opt/chef-workstation/bin"
    exit 1
  fi

  if [ -L "$native_bin_dir/git" ]; then
    linkinfo=$(readlink "$native_bin_dir/git")
    if [[ "$linkinfo" =~ "chef-workstation" ]]; then
      echo "ERROR: System git is symlinked to $linkinfo"
      exit 1
    fi
  fi

echo "Performing smoke test of packaged git"
  export_temp_dir
  pushd "$temp_dir"
    /opt/chef-workstation/gitbin/git config -l
    /opt/chef-workstation/gitbin/git clone https://github.com/chef/license-acceptance
  popd
  cleanup_temp_dir

echo "Performing smoke test of pushy-client"
  pushy-client -v

# Converted from original. Comment preserved...
# echo "Performing unit test of pushy-client"
#   TODO the unit tests are currently failing in master
#   export_gem_location_for "opscode-pushy-client"
#   pushd "$gem_location"
#     push-client -v
#     bundle install --quiet
#     bundle exec rake spec
#   popd
#   cleanup_temp_dir

echo "Performing smoke test for chef-sugar library"
  export_temp_dir
  pushd "$temp_dir"
    cat >sugar.rb <<SUGAR_RB
      require 'chef/sugar'
      log 'something' do
        not_if { _64_bit? }
      end
SUGAR_RB
    chef-apply sugar.rb
   popd
   cleanup_temp_dir


