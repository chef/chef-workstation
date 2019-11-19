#!/bin/bash

############################################################################
# What is this script?
#
# Chef Workstation uses a tool called Expeditor to manage version bumps,
# changelogs  and releases. This script updates the pinned version of
# Chef Infra Client to the latest stable release.
############################################################################

set -evx

# the gem doesn't seem to be available when this job kicks off so let's wait
sleep 600

# make sure we have rake for the tasks later
sed -i -r "s/^\s*gem \"chef\".*/  gem \"chef\", \"= ${EXPEDITOR_VERSION}\"/" components/gems/Gemfile
sed -i -r "s/^\s*gem \"chef-bin\".*/  gem \"chef-bin\", \"= ${EXPEDITOR_VERSION}\"/" components/gems/Gemfile
