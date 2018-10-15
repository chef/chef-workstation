+++
title = "Installing, Upgrading and Removing"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "999"
+++

Start by downloading the latest [Chef Workstation
package](https://downloads.chef.io/chef-workstation)

## Installing

### Mac

Open the downloaded `.dmg`, then the `.pkg` file to launch the installation.

### Windows

Open the downloaded `.msi` to launch the installation.

### Linux

Ubuntu, Debian, and related:

```bash
sudo dpkg -i /path/to/chef-workstation.deb
```

Red Hat, CentOS, and related:

```bash
sudo rpm -U /path-to/chef-workstation.rpm

```

## Upgrading

### From Chef Workstation or ChefDK

For all platforms, follow the same steps as listed under [Installing]({{< ref "#installing" >}}).

## Uninstalling

### Mac

Run ```uninstall_chef_workstation``` in your terminal.

### Windows

Use **Add / Remove Programs** to remove Chef Workstation.

### Linux

Ubuntu, Debian, and related:

```bash
sudo dpkg -P chef-workstation
```

Red Hat, CentOS, and related:

```bash
sudo rpm -e chef-workstation
```
