#!/bin/sh
chmod +x /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/log

bash /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist ~/Library/LaunchAgents/

echo "Sudo user is "
echo $SUDO_USER

# Unload first, this will help reload the service on further upgrades
sudo -u $SUDO_USER launchctl unload ~/Library/LaunchAgents/io.chef.chef-workstation.plist

sudo -u $SUDO_USER launchctl load ~/Library/LaunchAgents/io.chef.chef-workstation.plist
