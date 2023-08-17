+++
title = "knife ssl check"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_ssl_check.html", "/knife_ssl_check/"]

[menu]
  [menu.workstation]
    title = "knife ssl_check"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_ssl_check.md knife ssl_check"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++
<!-- markdownlint-disable-file MD036 -->

{{< readfile file="content/workstation/reusable/md/knife_ssl_check_summary.md" >}}

## Syntax

This subcommand has the following syntax:

``` bash
knife ssl check (options)
```

## Options

This subcommand has the following options:

`URL_or_URI`

: The URL or URI for the location at which the SSL certificate is located. Default value: the URL of the Chef Infra Server, as defined in the config.rb file.

## Examples

The following examples show how to use this knife subcommand:

**SSL certificate has valid X.509 properties**

{{< readfile file="content/workstation/reusable/md/knife_ssl_check_verify_server_config.md" >}}

**SSL certificate has invalid X.509 properties**

{{< readfile file="content/workstation/reusable/md/knife_ssl_check_bad_ssl_certificate.md" >}}

**Verify the SSL configuration for Chef Infra Client**

The SSL certificates that are used by Chef Infra Client may be verified
by specifying the path to the client.rb file. Use the `--config` option
(that is available to any knife command) to specify this path:

``` bash
knife ssl check --config /etc/chef/client.rb
```

**Verify an external server's SSL certificate**

``` bash
knife ssl check URL_or_URI
```

for example:

``` bash
knife ssl check https://www.chef.io
```
