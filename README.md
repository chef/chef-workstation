Chef Workstation
==================================

Chef Workstation installs everything you need to get started using Chef on Windows, Mac and Linux; and is currently focused around performing ad-hoc tasks on your server.  

## Getting Started

1. Download Chef Workstation
   
   * [Download Chef Workstation for Mac](http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/0.1.42/mac_os_x/10.13/chef-workstation-0.1.42-1.dmg)

   * [Download Chef Workstation for Windows](http://artifactory.chef.co/omnibus-current-local/com/getchef/chef-workstation/0.1.42/windows/2016/chef-workstation-0.1.42-1-x64.msi)

    ***Note:*** These links are internal and require Chef VPN. </br>
    ***Note2:*** These links may return a 404 if a build is in progress. Please try again in a few minutes.

2. Double-click the `.dmg` or `.msi` file to start the install process.

3. Open a command-line terminal, and try out some Chef-workstation commands
   
   * Run `chef -h` to view the available commands

   * Want to perform an ad-hoc task? Try
    
    `chef target converge <Target host|IP|SSH|WinRM> <Resource> <Resource Name> [attributes] [flags]`
    
    `chef target converge user@hostname user timmy`
    
    `chef target converge winrm://user@hostname:port user timmy`


## Building Chef-Workstation Packages
We use Omnibus to describe our packaging. Please review [chef-workstation/omnibus/README.MD](https://github.com/chef/chef-workstation/tree/master/omnibus) for further details.

## Questions or concerns?
Please join us in the *#shake-shack* channel on Slack!

*Notes:*
- We currently don't have ChefDK compatibility - it's coming soon on the next milestone.

## Copyright and License
Copyright 2008-2018, Chef Software, Inc.

**Note:** We are currently not open source. The plan is to make Chef Workstation open source at some point in the future.
