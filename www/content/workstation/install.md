+++
title = "Installing, Upgrading and Removing"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "999"
+++

Start by downloading the latest <a href="#" data-omnitruck-download="chef-workstation">Chef Workstation
package</a>.

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

### From Chef Workstation

For all platforms, follow the steps provided under [Installing]({{< ref "#installing" >}}).

### From ChefDK

#### Linux

The Chef Workstation package conflicts with an installed ChefDK package to prevent
unintentional upgrades.

Prior to installing Chef Workstation, first uninstall ChefDK:

Ubuntu, Debian, and related:

```bash
sudo dpkg -P chefdk
```

Red Hat, CentOS, and related:

```bash
sudo rpm -e chefdk
```

#### Other

For other platforms, follow the steps provided under [Installing]({{< ref "#installing" >}}).

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
