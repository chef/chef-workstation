+++
title = "Troubleshooting"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "40"
+++

## Chef Workstation Logs

Chef Workstation logs are stored in ` ~/.chef-workstation/logs`.

## Uninstall instructions

### Mac

Run the following code in your terminal:

```bash
rm -rf /opt/chef-workstation;
chefdk_binaries="berks chef chef-apply chef-shell chef-solo chef-vault cookstyle dco delivery foodcritic inspec kitchen knife ohai push-apply pushy-client pushy-service-manager chef-client"
  binaries="chef-run chefx $chefdk_binaries"

for binary in $binaries; do
  rm -f $PREFIX/bin/$binary
done
```

### Windows

Use **Add / Remove Programs** to remove the Chef Workstation product on the Microsoft Windows platform.

### Linux

Remove using respective package manager based on the distribution, for example, `yum` or `apt`.
