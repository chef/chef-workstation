+++
title = "chef-shell (executable)"
draft = false

gh_repo = "chef-workstation"

aliases = ["/chef_shell.html", "/chef_shell/"]

[menu]
  [menu.workstation]
    title = "chef-shell (executable)"
    identifier = "chef_workstation/chef_workstation_tools/chef_shell.md chef-shell (executable)"
    parent = "chef_workstation/chef_workstation_tools"
    weight = 40
+++
<!-- markdownlint-disable-file MD024 -->

{{< readfile file="content/reusable/md/chef_shell_summary.md" >}}

The chef-shell executable is run as a command-line tool.

## Modes

{{< readfile file="content/reusable/md/chef_shell_modes.md" >}}

## Options

This command has the following syntax:

``` bash
chef-shell OPTION VALUE OPTION VALUE ...
```

This command has the following options:

`-a`, `--standalone`

: Run chef-shell in standalone mode.

`-c CONFIG`, `--config CONFIG`

: The configuration file to use.

`-h`, `--help`

: Show help for the command.

`-j PATH`, `--json-attributes PATH`

: The path to a file that contains JSON data. Use this option to define a `run_list` object. For example, a JSON file similar to:

  ``` javascript
  "run_list": [
    "recipe[base]",
    "recipe[foo]",
    "recipe[bar]",
    "role[webserver]"
  ],
  ```

  may be used by running `chef-shell -j path/to/file.json`.

  In certain situations this option may be used to update `normal` attributes.

  {{< warning >}}

  Any other attribute type that is contained in this JSON file will be
  treated as a `normal` attribute. Setting attributes at other precedence
  levels is not possible. For example, attempting to update `override`
  attributes using the `-j` option:

  ```javascript
  {
    "name": "dev-99",
    "description": "Install some stuff",
    "override_attributes": {
      "apptastic": {
        "enable_apptastic": "false",
        "apptastic_tier_name": "dev-99.bomb.com"
      }
    }
  }
  ```

  will result in a node object similar to:

  ```javascript
  {
    "name": "maybe-dev-99",
    "normal": {
      "name": "dev-99",
      "description": "Install some stuff",
      "override_attributes": {
        "apptastic": {
          "enable_apptastic": "false",
          "apptastic_tier_name": "dev-99.bomb.com"
        }
      }
    }
  }
  ```

  {{< /warning >}}

`-l LEVEL`, `--log-level LEVEL`

: The level of logging to be stored in a log file.

`-o RUN_LIST_ITEM`, `--override-runlist RUN_LIST_ITEM`

: Replace the current run-list with the specified items. Only applicable when also using `solo` or `server` modes.

`-s`, `--solo`

: Run chef-shell in chef-solo mode.

`-S CHEF_SERVER_URL`, `--server CHEF_SERVER_URL`

: The URL of the Chef Infra Server.

`-v`, `--version`

: The Chef Infra Client version.

`-z`, `--client`

: Run chef-shell in Chef Infra Client mode.

## Configure

{{< readfile file="content/reusable/md/chef_shell_config.md" >}}

### chef-shell.rb

{{< readfile file="content/reusable/md/chef_shell_config_rb.md" >}}

### Run as a Chef Infra Client

{{< readfile file="content/reusable/md/chef_shell_run_as_chef_client.md" >}}

## Debugging Cookbooks

{{< readfile file="content/reusable/md/chef_shell_breakpoints.md" >}}

### Step Through Run-list

{{< readfile file="content/reusable/md/chef_shell_step_through_run_list.md" >}}

### Debug Existing Recipe

{{< readfile file="content/reusable/md/chef_shell_debug_existing_recipe.md" >}}

### Advanced Debugging

{{< readfile file="content/reusable/md/chef_shell_advanced_debug.md" >}}

## Manipulating Chef Infra Server Data

{{< readfile file="content/reusable/md/chef_shell_manage.md" >}}

## Examples

The following examples show how to use chef-shell.

### "Hello World"

{{< readfile file="content/reusable/md/chef_shell_example_hello_world.md" >}}

### Get Specific Nodes

{{< readfile file="content/reusable/md/chef_shell_example_get_specific_nodes.md" >}}
