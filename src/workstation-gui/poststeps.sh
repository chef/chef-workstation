#!/bin/sh
echo "nikhil"

echo "$PWD"
cd /opt/chef-workstation/embedded/service/workstation-gui

echo "$PWD"

echo "Inside the poststeps" >> bashlog.txt
# Setting up the permissions for the tmp and log directories
chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp/
chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/log/

echo "Updated the persmissions for tmp and log" >> bashlog.txt
# Regenerate the secrets
rm config/credentials.yml.enc
rm config/master.key
echo "Deleted files" >> bashlog.txt
rake secrets:regenerate
echo "Regerated the secrets" >> bashlog.txt

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.workstation.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/io.chef.workstation.plist

launchctl start ~/Library/LaunchAgents/io.chef.workstation.plist