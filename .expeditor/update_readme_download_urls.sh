#!/bin/bash
#
# After the release build expeditor will update the readme to include new
# package urls.

set -evx

mac_url=http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/$(cat VERSION)/mac_os_x/10.13/chef-workstation-$(cat VERSION)-1.dmg
windows_url=http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/$(cat VERSION)/windows/2016/chef-workstation-$(cat VERSION)-1-x64.msi
debian_url=http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/$(cat VERSION)/ubuntu/16.04/chef-workstation_$(cat VERSION)-1_amd64.deb
el_url=http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/$(cat VERSION)/el/7/chef-workstation-$(cat VERSION)-1.el6.x86_64.rpm

sed -i -r "s/(^   \* \[.*Mac\]\().*(\))/\1${mac_url//\//\\/}\2/" README.md
sed -i -r "s/(^   \* \[.*Windows\]\().*(\))/\1${windows_url//\//\\/}\2/" README.md
sed -i -r "s/(^   \* \[.*Debian\]\().*(\))/\1${debian_url//\//\\/}\2/" README.md
sed -i -r "s/(^   \* \[.*Enterprise Linux\]\().*(\))/\1${el_url//\//\\/}\2/" README.md

git add .
git commit -m "Update readme links to $(cat VERSION) by Expeditor"
git push origin master
