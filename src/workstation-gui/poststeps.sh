#!/bin/sh
chmod +x /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/log

echo "Generating seed secrets"
bash /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh || echo "Execution of secrets.sh failed"

if [ ! -d "$HOME/Library/LaunchAgents" ]; then
  echo "Creating LaunchAgents folder"
  mkdir -p "$HOME/Library/LaunchAgents" || echo "LaunchAgents folder creation failed"
fi

echo "Copying plist to LaunchAgents"
cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist $HOME/Library/LaunchAgents/. || echo "plist copy to LaunchAgents failed"

# Unload first, this will help reload the service on further upgrades
sudo -u $USER launchctl unload $HOME/Library/LaunchAgents/io.chef.chef-workstation.plist

echo "Loading agent to start puma service"
sudo -u $USER launchctl load $HOME/Library/LaunchAgents/io.chef.chef-workstation.plist
