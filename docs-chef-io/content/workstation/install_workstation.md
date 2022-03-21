+++
title = "Install Chef Workstation"
draft = false

gh_repo = "chef-workstation"

aliases = ["/install_workstation.html", "/install_dk.html", "/workstation_windows.html", "/dk_windows.html", "/install_workstation/"]

[menu]
  [menu.workstation]
    title = "Install"
    identifier = "chef_workstation/install_workstation.md Install Chef Workstation"
    parent = "chef_workstation"
    weight = 20
+++
<!-- markdownlint-disable-file MD033 -->

{{% chef_workstation %}}

## Supported Platforms

Supported Host Operating Systems:

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr class="header">
<th>Platform</th>
<th>Version</th>
</tr>
</thead>
<tbody>
<tr class="even">
<td>Amazon Linux</td>
<td>2</td>
</tr>
<tr class="odd">
<td>Apple macOS</td>
<td>10.15, 11, 12</td>
</tr>
<tr class="even">
<td>Windows</td>
<td>10, 11, Server 2012, Server 2012 R2, Server 2016, Server 2019, Server 2022</td>
</tr>
<tr class="odd">
<td>Red Hat Enterprise Linux / CentOS</td>
<td>7.x, 8.x</td>
</tr>
<tr class="even">
<td>Ubuntu</td>
<td>16.04, 18.04, 20.04</td>
</tr>
<tr class="odd">
<td>Debian</td>
<td>9, 10, 11</td>
</tr>
</tbody>
</table>

## System Requirements

Minimum system requirements:

- RAM: 4GB
- Disk: 8GB
- Additional memory and storage space may be necessary to take advantage of Chef Workstation tools such as Test Kitchen which creates and manages virtualized test environments.

Additional Chef Workstation App Requirements:

- On Linux you must have a graphical window manager running with support for system tray icons. For some distributions you may also need to install additional libraries. After you install the Chef Workstation package from the terminal, the post-install message will tell you which, if any, additional libraries are required to run the Chef Workstation App.

## Installation

The Chef Workstation installer must run as a privileged user.

Chef Workstation installs to `/opt/chef-workstation/` on macOS / Linux
and `C:\opscode\chef-workstation\` on Windows. These file locations
help avoid interference between these components and other
applications that may be running on the target machine.

### macOS Install

1. Visit the [Chef Workstation downloads page](https://www.chef.io/downloads/tools/workstation?os=mac_os_x) and select the appropriate package for your macOS version. Select on the **Download** button.
1. Follow the steps to accept the license and install Chef Workstation.

Alternately, install Chef Workstation using the [Homebrew](https://brew.sh/) package manager:

`brew install --cask chef-workstation`

### Windows Install

1. Visit the [Chef Workstation downloads page](https://www.chef.io/downloads/tools/workstation?os=windows) and select the appropriate package for your Windows version. Click on the **Download** button.
1. Follow the steps to accept the license and install Chef Workstation. You will have the option to change your install location; by default the installer uses the `C:\opscode\chef-workstation\` directory.
1. **Optional:** Set the default shell. On Windows it is strongly recommended to use Windows PowerShell instead of `cmd.exe`.

Alternately, install Chef Workstation using the [Chocolatey](https://chocolatey.org/) package manager:

`choco install chef-workstation`

#### Headless Unattended Install

"Headless" systems are configured to operate without a monitor (the "head") keyboard, and mouse. They are usually administered remotely using protocols such as SSH or WinRM.

Chef Workstation can be installed on a headless system using the `msiexec` command and flags to skip the installation of the Chef Workstation Application, which requires a GUI. Run the following command in Windows PowerShell or `cmd.exe`, replacing `MsiPath` with the path of the downloaded Chef Workstation installer.

```powershell
msiexec /q /i MsiPath ADDLOCAL=ALL REMOVE=ChefWSApp
```

#### Spaces and Directories

{{% windows_spaces_and_directories %}}

#### Top-level Directory Names

{{% windows_top_level_directory_names %}}

### Linux

1. Visit the [Chef Workstation downloads page](https://www.chef.io/downloads/tools/workstation) and download the appropriate package for your distribution:

    - Red Hat Enterprise Linux

      ```bash
      wget https://packages.chef.io/files/stable/chef-workstation/21.10.640/el/8/chef-workstation-21.10.640-1.el8.x86_64.rpm
      ```

    - Debian/Ubuntu

      ``` bash
      wget https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/20.04/chef-workstation_21.10.640-1_amd64.deb
      ```

1. Use your distribution's package manager to install Chef Workstation:
   - Red Hat Enterprise Linux:

        ``` bash
        yum localinstall chef-workstation-21.10.640-1.el8.x86_64.rpm
        ```

   - Debian/Ubuntu:

        ``` bash
        dpkg -i chef-workstation_21.10.640-1_amd64.deb
        ```

## Verify the Installation

To verify the installation, run:

``` shell
chef -v
```

Which returns the versions of all installed Chef tools:

``` shell
Chef Workstation version: 21.10.640
Chef Infra Client version: 17.6.18
Chef InSpec version: 4.46.13
Chef CLI version: 5.4.2
Chef Habitat version: 1.6.351
Test Kitchen version: 3.1.0
Cookstyle version: 7.25.6
```

## Upgrading

To upgrade from ChefDK or an earlier release of Chef Workstation, follow the instructions provided under [Installing]({{< ref "install_workstation.md" >}}).

## Uninstalling

### Mac Uninstall

Run `uninstall_chef_workstation` in your terminal.

### Windows Uninstall

Use **Add / Remove Programs** to remove Chef Workstation.

### Linux Uninstall

Ubuntu, Debian, and related:

```bash
sudo dpkg -P chef-workstation
```

Red Hat, CentOS, and related:

```bash
sudo yum remove chef-workstation
```

## Next Steps

Now that you've installed Chef Workstation, proceed to the [Setup]({{< relref "getting_started.md" >}}) guide to configure your Chef Workstation installation.
