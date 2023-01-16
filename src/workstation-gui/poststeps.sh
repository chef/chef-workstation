#!/bin/sh
chmod +x /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/log

echo "Generating seed secrets"
bash /opt/chef-workstation/embedded/service/workstation-gui/secrets.sh
echo $?
echo "Exit-code of secrets.sh script run"

if [ ! -d "$HOME/Library/LaunchAgents" ]; then
  echo $HOME
  echo "Creating LaunchAgents folder"
  mkdir -p "$HOME/Library/LaunchAgents"
  echo $?
  echo "Exit-code of LaunchAgents folder creation"
fi

echo "Copying plist to LaunchAgents"
cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist $HOME/Library/LaunchAgents/.
echo $?
echo "Exit-code of plist copy"

# Unload first, this will help reload the service on further upgrades
sudo -u $USER launchctl unload $HOME/Library/LaunchAgents/io.chef.chef-workstation.plist

sudo -u $USER launchctl load $HOME/Library/LaunchAgents/io.chef.chef-workstation.plist
