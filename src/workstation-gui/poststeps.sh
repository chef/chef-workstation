#!/bin/sh

# echo "nikhil"

# echo "$PWD"
# cd /opt/chef-workstation/embedded/service/workstation-gui

# echo "$PWD"

chmod +x /opt/chef-workstation/embedded/service/workstation-gui/config/server.sh

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.workstation.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/io.chef.workstation.plist