#!/bin/sh
echo "nikhil"

echo "$PWD"
cd /opt/chef-workstation/embedded/service/workstation-gui

echo "$PWD"

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.workstation.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/io.chef.workstation.plist

launchctl start ~/Library/LaunchAgents/io.chef.workstation.plist