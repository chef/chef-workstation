Chef Workstation
==================================

Chef Workstation installs everything you need to get started using Chef on Windows, Mac and Linux; and is currently focused around performing ad-hoc tasks on your server.

## Getting Started

1. Download [Chef Workstation](https://downloads.chef.io/chef-workstation)

2. Double-click the `.dmg` or `.msi` file to start the install process. Or install the Linux package for your platform.

3. Open a command-line terminal, and try out some chef-cli commands

   * Run `chef -h` to view the available commands

   * Want to perform an ad-hoc task? Try

    `chef-run <Target host|IP|SSH|WinRM> <Resource> <Resource Name> [properties] [flags]`

    `chef-run user@hostname user timmy`

    `chef-run winrm://user@hostname:port user timmy`

## Building Chef-Workstation Packages

We use Omnibus to describe our packaging. Please review [chef-workstation/omnibus/README.MD](https://github.com/chef/chef-workstation/tree/master/omnibus) for further details.

## Copyright and License

Code released under the [Apache license](LICENSE). Images and any trademarked content are copyrighted by [Chef Software, Inc.](https://www.chef.io).
