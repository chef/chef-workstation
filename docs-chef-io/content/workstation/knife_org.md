+++
title = "knife org"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_org.html", "/knife_org/"]

[menu]
  [menu.workstation]
    title = "knife org"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_org.md knife org"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++

The `knife org` subcommand is used to manage organizations and users in
Chef Server 12.

{{< note >}}

Administrator permissions are required to add, remove, or edit users. To
manage organizations, or change a user's assignment to an organization,
the pivotal key is required. Rather than using the knife-org commands
below, which are an implementation detail, use the equivalent 
"user-" and "org-" subcommands directly on the Chef Infra Server. 
Those wrappered subcommands already have the needed permissions applied and access 
to sensitive commands will then be centralized. [See chef-server-ctl for
details](/ctl_chef_server/).

{{< /note >}}

{{< note >}}

Review the list of [common options](/workstation/knife_options/) available to
this (and all) knife subcommands and plugins.

{{< /note >}}

config.rb Configuration [knife_org-knife-rb-configuration]
=======================

Unlike other knife subcommands the subcommands in the knife-org plugin
make API calls against the root of your Chef Infra Server installation's
API endpoint.

Typically the `chef_server_url` for your Chef Infra Server installation
may look like this:

``` ruby
chef_server_url 'https://chef.yourdomain.com/organizations/ORG_NAME'
```

To configure knife-opc, set the `chef_server_root` option to the root of
your Chef Infra Server installation:

``` ruby
chef_server_root 'https://chef.yourdomain.com/'
```

If your `chef_server_url` configuration ends with
`/organizations/ORG_NAME` (as shown above), this setting will default to
`https://chef.yourdomain.com/`.

{{< note >}}

On Chef Server 12, the majority of the commands provided by this plugin
can be accessed via `chef-server-ctl` wrapper commands. [See
chef-server-ctl for details](/ctl_chef_server/).

{{< /note >}}

{{< note >}}

User subcommands or option are added under knife user. See knife user for
details](/workstation/knife_user/).

{{< /note >}}

org create 
==============

Creates a new Chef Infra Server organization. The private key for the
organization's validator client is returned.

### Syntax

This argument has the following syntax:

``` bash
knife org create ORG_NAME ORG_FULL_NAME (options)
```

### Options

This argument has the following options:

`-f FILENAME`, `--filename FILENAME`

: Write private key to `FILENAME` rather than `STDOUT`.

`-a USER_NAME`, `--association_user USER_NAME`

: Associate `USER_NAME` with the organization after creation.

### Example

``` bash
knife org create acme2 "The Other Acme" -a arno
-----BEGIN RSA PRIVATE KEY-----
[...]
-----BEGIN RSA PRIVATE KEY-----
```

org list
============

Show a list of all organizations in your Chef Infra Server installation.

### Syntax

This argument has the following syntax:

``` bash
knife org list (options)
```

### Options

This argument has the following options:

`-w`, `--with-uri`

: Show corresponding URIs.

`-a`, `--all-orgs`

: Display auto-generated hidden orgs.

### Example

``` bash
knife org list -w -a
acme: https://chef-server.fqdn/organizations/acme
```

org show 
==========

Shows the details of an organization in your Chef Infra Server
installation.

### Syntax

This argument has the following syntax:

``` bash
knife org show ORG_NAME
```

### Example

``` bash
knife org show acme
full_name: Acme
guid:      cc9f9d0d4f6e7e35272e327e22e7affc
name:      acme
```

org edit
==============

Edits the given Chef Infra Server organization.

### Syntax

This argument has the following syntax:

``` bash
knife org edit ORG_NAME
```

### Example

knife org edit Acme -e nano
{"name"=>"Acme", "full_name"=>"Acme Z", "guid"=>"dea05074c4566f81d9d3228f4ad9bcd3"}
Saved Acme.

org delete
==============

Deletes the given Chef Infra Server organization.

### Syntax

This argument has the following syntax:

``` bash
knife org delete ORG_NAME
```

### Example

``` bash
knife org delete acme2
Do you want to delete the organization acme2? (Y/N) Y
full_name: The Other Acme
guid:      2adec1140cf777a15d82d9099304da71
name:      acme2
```

## org user add

Adds a user to an organization. Requires that the named organization and
user both exist.

### Syntax

This argument has the following syntax:

``` bash
knife org user add ORG_NAME USER_NAME
```

### Options

This argument has the following options:

`-a`, `--admin`

: Add user to admin group.


### Example

``` bash
knife org user add acme2 alice
```

org user remove
===================

Removes a user from an organization. Requires that the named
organization and user both exist, and that the user is currently
associated with the organization.

### Syntax

This argument has the following syntax:

``` bash
knife org user remove ORG_NAME USER_NAME
```

### Options

This argument has the following options:

`-f`, `--force`

: Force removal of user from the organization's admins and billing-admins group.

### Example

``` bash
knife org user remove acme2 alice
```
