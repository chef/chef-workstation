Chef Workstation
==================================

Chef Workstation installs everything you need to get started using Chef on Windows, Mac and Linux; and is currently focused around performing ad-hoc tasks on your server.

## Getting Started

1. Download [Chef Workstation](https://downloads.chef.io/chef-workstation)

2. Double-click the `.dmg` or `.msi` file to start the install process, or use the package manager for your Linux distribution.

3. Open a terminal, and try out an ad-hoc task. Here's the general usage:

    `chef-run  [flags] <Target host|IP|SSH|WinRM> <Resource> <Resource Name> [properties]`

  * Install the 'ntp' package on 'hostname' over ssh, using password from the environment:

    `chef-run username:$PASSWORD@hostname package ntp`

  * Create user 'timmy' on 'hostname' over winrm:

    `chef-run winrm://username@hostname user timmy`

  * Run the recipe 'nginx::passenger' on 'hostname' over ssh:

    `chef-run ssh://hostname nginx::passenger`

4. Use `chef-run -h` for additional information about usage and available flags.

## Building Chef-Workstation Packages

We use Omnibus to describe our packaging. Please review [chef-workstation/omnibus/README.MD](https://github.com/chef/chef-workstation/tree/master/omnibus) for further details.

## Copyright and License

Code released under the [Apache license](LICENSE). Images and any trademarked content are Copyright 2018 by [Chef Software, Inc.](https://www.chef.io).
