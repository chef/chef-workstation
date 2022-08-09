#!/bin/sh
chmod +x /opt/chef-workstation/embedded/service/workstation-gui/config/server.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/io.chef.chef-workstation.plist