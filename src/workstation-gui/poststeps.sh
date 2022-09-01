#!/bin/sh

# echo "nikhil"

# echo "$PWD"
# cd /opt/chef-workstation/embedded/service/workstation-gui

# echo "$PWD"

# mv /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/ruby/3.0.0/gems/* /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/gems

# mv /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/ruby/3.0.0/extensions/x86_64-darwin-19/3.0.0/* /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/extensions/x86_64-darwin-19/3.0.0

# mv /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/ruby/3.0.0/specifications/* /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/specifications

# mv /opt/chef-workstation/embedded/lib/ruby/gems/3.0.0/ruby/3.0.0/bin/* /opt/chef-workstation/bin

bash secrets.sh

chmod +x /opt/chef-workstation/embedded/service/workstation-gui/config/server.sh

chmod -R 777 /opt/chef-workstation/embedded/service/workstation-gui/tmp

cp /opt/chef-workstation/embedded/service/workstation-gui/config/io.chef.chef-workstation.plist ~/Library/LaunchAgents/

launchctl load ~/Library/LaunchAgents/io.chef.chef-workstation.plist