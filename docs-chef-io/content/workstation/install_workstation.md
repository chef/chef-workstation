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

{{< readfile file="content/workstation/reusable/md/chef_workstation.md" >}}

For general information about downloading Chef products, see the [Chef download documentation](/download/).

## Supported Platforms

The following table lists the commercially supported platforms and versions for Chef Workstation:

{{< readfile file = "content/workstation/reusable/md/workstation_supported_platforms.md" >}}

### Derived Platforms

The following table lists supported derived platforms and versions for Chef Workstation.

See our policy on [support for derived platforms](/platforms/#support-for-derived-platforms) for more information.

{{< readfile file = "content/workstation/reusable/md/workstation_supported_derived_platforms.md" >}}

## System Requirements

Minimum system requirements:

- RAM: 4GB
- Disk: 8GB
- Additional memory and storage space may be necessary to take advantage of Chef Workstation tools such as Test Kitchen which creates and manages virtualized test environments.

Additional Chef Workstation App Requirements:

- On Linux, you must have a graphical window manager running with support for system tray icons. For some distributions you may also need to install additional libraries. After you install the Chef Workstation package from the terminal, the post-install message will tell you which, if any, additional libraries are required to run the Chef Workstation App.

## Installation

The Chef Workstation installer must run as a privileged user.

Chef Workstation installs to `/opt/chef-workstation/` on macOS / Linux
and `C:\opscode\chef-workstation\` on Windows. These file locations
help avoid interference between these components and other
applications that may be running on the target machine.

### macOS Install

1. Visit [Chef Downloads](https://www.chef.io/downloads) to download a Chef Workstation package.
1. Follow the steps to accept the license and install Chef Workstation.

Alternatively, install Chef Workstation using the [Homebrew](https://brew.sh/) package manager:

`brew install --cask chef-workstation`

### Windows Install

1. Visit [Chef Downloads](https://www.chef.io/downloads) to download a Chef Workstation package.
1. Follow the steps to accept the license and install Chef Workstation. You will have the option to change your install location; by default the installer uses the `C:\opscode\chef-workstation\` directory.
1. **Optional:** Set the default shell. On Windows it is strongly recommended to use Windows PowerShell instead of `cmd.exe`.

Alternatively, install Chef Workstation using the [Chocolatey](https://chocolatey.org/) package manager:

`choco install chef-workstation`

#### Headless Unattended Install

"Headless" systems are configured to operate without a monitor (the "head") keyboard, and mouse. They are usually administered remotely using protocols such as SSH or WinRM.

Chef Workstation can be installed on a headless system using the `msiexec` command and flags to skip the installation of the Chef Workstation Application, which requires a GUI. Run the following command in Windows PowerShell or `cmd.exe`, replacing `MsiPath` with the path of the downloaded Chef Workstation installer.

```powershell
msiexec /q /i MsiPath ADDLOCAL=ALL REMOVE=ChefWSApp
```

#### Spaces and Directories

{{< readfile file="content/reusable/md/windows_spaces_and_directories.md" >}}

#### Top-level Directory Names

{{< readfile file="content/reusable/md/windows_top_level_directory_names.md" >}}

### Linux

1. Visit the [Chef Downloads page](https://www.chef.io/downloads) or download the appropriate package for your distribution:

    - Red Hat Enterprise Linux

      ```bash
      wget https://packages.chef.io/files/stable/chef-workstation/<WORKSTATION_VERSION>/el/<RHEL_VERSION>/chef-workstation-<WORKSTATION_VERSION>-1.el<RHEL_VERSION>.x86_64.rpm
      ```

      For example:

      ```sh
      wget https://packages.chef.io/files/stable/chef-workstation/24.4.1064/el/8/chef-workstation-24.4.1064-1.el8.x86_64.rpm
      ```


    - Debian/Ubuntu

      ``` bash
      wget https://packages.chef.io/files/stable/chef-workstation/<WORKSTATION_VERSION>/ubuntu/<UBUNTU_VERSION>/chef-workstation_<WORKSTATION_VERSION>-1_amd64.deb
      ```

      For example:

      ```sh
      wget https://packages.chef.io/files/stable/chef-workstation/24.4.1064/ubuntu/20.04/chef-workstation_24.4.1064-1_amd64.deb
      ```

1. Use your distribution's package manager to install Chef Workstation:

   - Red Hat Enterprise Linux:

     ``` bash
     yum localinstall chef-workstation-<WORKSTATION_VERSION>-1.el<RHEL_VERSION>.x86_64.rpm
     ```

     For example:

     ``` bash
     yum localinstall chef-workstation-24.4.1064-1.el8.x86_64.rpm
     ```

   - Debian/Ubuntu:

     ``` bash
     dpkg -i chef-workstation_<WORKSTATION_VERSION>-1_amd64.deb
     ```

     For example:

     ```sh
     dpkg -i chef-workstation_24.4.1064-1_amd64.deb
     ```

See the [Chef Workstation release notes](/release_notes_workstation/) or the [Omnitruck API](https://omnitruck.chef.io/stable/chef-workstation/versions/all) for supported version numbers.

## Verify the Installation

To verify the installation, run:

``` shell
chef -v
```

Which returns the versions of all installed Chef tools:

``` shell
Chef Workstation version: 24.4.1064
Chef Infra Client version: 18.4.12
Chef InSpec version: 5.22.40
Chef CLI version: 5.6.14
Chef Habitat version: 1.6.652
Test Kitchen version: 3.6.0
Cookstyle version: 7.32.8
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
