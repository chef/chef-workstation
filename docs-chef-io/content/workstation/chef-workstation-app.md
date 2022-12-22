+++
title = "Chef Workstation App"
draft = false

gh_repo = "chef-workstation"

[menu]
  [menu.workstation]
    title = "Chef Workstation App"
    identifier = "chef_workstation/chef_workstation_tools/chef_workstation_app.md Chef Workstation App"
    parent = "chef_workstation/chef_workstation_tools"
    weight = 61
+++

The Chef Workstation App (CWA) is an early release desktop application that provides additional services for Chef Workstation:

* Run cookbook actions in local repositories
* Update checking and notifications
* Chef Workstation version information

Additional features and integrations will be rolled out in future updates.

## Running the Chef Workstation App

### Windows

Launch Chef Workstation App from the Chef Workstation folder in the Start menu.

### Linux

Start Chef Workstation App by running the command `chef-workstation-app`.

#### Notes

1. Chef Workstation App requires a running display manager with support for system tray icons.
1. On some distributions you may need to install additional libraries. The post-install message shown when you install the Chef Workstation package from the terminal will tell you which -- if any -- additional libraries are required to run Chef Workstation App.

### Mac

Start `Chef Workstation App` from your Applications folder.

## Managing cookbooks

To access the cookbook management dashboard, select "Manage Cookbooks" in the CWA tray app menu (Windows) or the application menu (Mac).

### Linking repositories

The 'Chef Repositories' view lets you to choose folders in your computer that represent the chef-repo's you need to work on. Click 'Add New' to select a chef-repo folder. The cookbooks present in each of these repositories will be listed in the dashboard's 'Cookbooks' view. The linked chef-repo's are persisted so you only need to add them once in the cookbook management dashboard. The repository name displayed in the dashboard is the same as the folder name.

### Accessing cookbook actions

At present, the 'Cookbooks' view lets you upload the selected cookbooks to the configured Chef Infra Server. To upload a cookbook, click the 'Upload' button corresponding to the cookbook.

{{< note >}}

There is a known limitation where the profile settings in `~/.chef/credentials` are not parsed correctly, causing a request signing error to show up when you upload a cookbook. To overcome this issue, please copy your knife `config.rb` to `~/.chef`. This is a temporary workaround and a proper fix will be introduced soon.

{{< /note >}}

## Disabling Automatic Update Checks

To disable CWA's automatic update checking, add or modify the `enable` setting under `updates` in [config.toml]({{< ref "config.md#updates" >}}):

```toml
[updates]
enable=false
```

## Setting Update Channel

To set the channel used for update checking, bring up the CWA tray app menu (Windows/Linux) or the application menu (Mac) and select "About Chef Workstation".

Select the "Channel" button and choose your preferred channel. This will trigger an immediate update check.

```toml
[updates]
channel="current"
```
