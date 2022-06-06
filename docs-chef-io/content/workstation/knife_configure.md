+++
title = "knife configure"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_configure.html", "/knife_configure/"]

[menu]
  [menu.workstation]
    title = "knife configure"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_configure.md knife configure"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++
<!-- markdownlint-disable-file MD036 -->

{{% chef-workstation/knife_configure_summary %}}

## Syntax

This subcommand has the following syntax when creating a credentials file:

``` bash
knife configure (options)
```

and the following syntax when creating a client.rb file:

``` bash
knife configure client DIRECTORY
```

## Options

{{< note >}}

{{% chef-workstation/knife_common_see_common_options_link %}}

{{< /note >}}

This subcommand has the following options for use when configuring a
config.rb file:

`--admin-client-name NAME`

: The name of the client, typically the name of the admin client.

`--admin-client-key PATH`

: The path to the private key used by the client, typically a file
    named `admin.pem`.

`-i`, `--initial`

: Create a API client, typically an administrator client on a
    freshly-installed Chef Infra Server.

`-r REPO`, `--repository REPO`

: The path to the chef-repo.

`--validation-client-name NAME`

: The name of the validation client, typically a client named
    chef-validator.

`--validation-key PATH`

: The path to the validation key used by the client, typically a file
    named chef-validator.pem.

{{< note >}}

{{% chef-workstation/knife_common_see_all_config_options %}}

{{< /note >}}

## Examples

The following examples show how to use this knife subcommand:

**Configure credentials file**

``` bash
knife configure
```

**Configure client.rb**

``` bash
knife configure client '/directory'
```
