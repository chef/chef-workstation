+++
title = "Troubleshooting"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    Weight = "1000"
+++

## Chef Workstation Logs 

Chef Workstation logs are stored in ` ~/.chef-workstation/logs`. 

## Uninstall instructions 

### Mac

Please run the following code in your terminal: 

```
rm -rf /opt/chef-workstation;
chefdk_binaries="berks chef chef-apply chef-shell chef-solo chef-vault cookstyle dco delivery foodcritic inspec kitchen knife ohai push-apply pushy-client pushy-service-manager chef-client"
  binaries="chef-run chefx $chefdk_binaries"

for binary in $binaries; do
  rm -f $PREFIX/bin/$binary
done
``` 

### Windows

Please use **Add / Remove Programs** to remove the Chef Workstation product on the Microsoft Windows platform. 

### Linux

Please remove using respective package manager based on the distro. (i.e: `yum`, `apt` etc. )