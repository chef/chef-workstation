#!/bin/bash

# Generate the access_key
if openssl version
then
  access_key=$(openssl rand -hex 16)
else
  access_key=$($RANDOM | md5sum | head -c 20)
fi

#access_key=$(openssl rand -hex 16)
echo "$access_key"
echo "$access_key" >> /opt/chef-workstation/service.txt

echo "$PWD"
echo "removing the old credentials"
rm config/credentials.yml.enc
rm config/master.key
/opt/chef-workstation/embedded/bin/bundle exec /opt/chef-workstation/embedded/bin/rake secrets:regenerate["$access_key"]
echo "After running the secrets regenerate"
