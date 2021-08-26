#!/bin/bash

#
# Copyright:: Copyright (c) 2020 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

############################################################################
# What is this script?
#
# Chef Workstation uses Expeditor (internal CI bot) to manage the bundled
# version of the the Chef Habitat CLI. This script will be run by Expeditor
# when a new version of habitat is published to the stable channel, to ensure that
# Workstation is updated to and validated with the most recent stable version of
# Chef Habitat.
############################################################################

set -evx

BASE_URL="http://packages.chef.io/files/stable/habitat/latest"
winsha=$(curl "$BASE_URL/hab-x86_64-windows.zip.sha256sum" --silent | cut -d ' ' -f 1)
darwinsha=$(curl "$BASE_URL/hab-x86_64-darwin.zip.sha256sum" --silent | cut -d ' ' -f 1)
linsha=$(curl "$BASE_URL/hab-x86_64-linux.tar.gz.sha256sum" --silent | cut -d ' ' -f 1)
sw_def_file="omnibus/config/software/habitat.rb"

MANIFEST_URL="$BASE_URL/manifest.json"
MANIFEST=$(curl --silent "$MANIFEST_URL")
version=$(jq -r '.version'<<< "$MANIFEST")

sed -i -r "s/windows_sha = .*/windows_sha = \"$winsha\"/" $sw_def_file
sed -i -r "s/linux_sha = .*/linux_sha = \"$linsha\"/" $sw_def_file
sed -i -r "s/darwin_sha = .*/darwin_sha = \"$darwinsha\"/" $sw_def_file
sed -i -r "s/^default_version \".*/default_version \"$version\"/" $sw_def_file

branch="expeditor/hab-${version}"
git checkout -b "$branch"
git add $sw_def_file
git commit --message "Bump habitat to $version." --message "This pull request was triggered automatically via Expeditor when habitat v. $version was merged to main." --message "This change falls under the obvious fix policy so no Developer Certificate of Origin (DCO) sign-off is required."
open_pull_request

# Get back to main and cleanup the leftovers - any changed files left over at the end of this script will get committed to main.
git checkout -
git branch -D "$branch"

