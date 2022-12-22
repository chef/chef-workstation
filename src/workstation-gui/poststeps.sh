#!/bin/sh
chmod +x /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/log

bash /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist ~/Library/LaunchAgents/

# Unload first, this will help reload the service on further upgrades
sudo -u $USER launchctl unload ~/Library/LaunchAgents/io.chef.chef-workstation.plist

sudo -u $USER launchctl load ~/Library/LaunchAgents/io.chef.chef-workstation.plist
