#!/bin/bash
#
# After the release build expeditor will update the readme to include new
# package urls. Note if the build fails these links wont work. Also, they won't
# work during the build because we will have updated the readme before the
# artifacts are ready.

set -evx

mac_url=http://artifactory.chef.co/omnibus-unstable-local/com/getchef/chef-workstation/$(cat VERSION)/mac_os_x/10.13/chef-workstation-$(cat VERSION)-1.dmg
windows_url=http://artifactory.chef.co/omnibus-unstable-local/com/getchef/chef-workstation/$(cat VERSION)/windows/2016/chef-workstation-$(cat VERSION)-1-x64.msi

sed -i -r "s/(^  \* \[.*Mac\]\().*(\))/\1${mac_url//\//\\/}\2/" README.md
sed -i -r "s/(^  \* \[.*Windows\]\().*(\))/\1${windows_url//\//\\/}\2/" README.md
