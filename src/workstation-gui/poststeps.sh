#!/bin/sh
echo "nikhil"

echo "$PWD"
cd /opt/chef-workstation/embedded/service/workstation-gui

echo "$PWD"

bundle exec /opt/chef-workstation/embedded/lib/ruby/3.0.0/bin/puma -C config/puma.rb