+++
title = "Getting Started"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "1"
+++

## Overview

Chef Workstation gives you everything you need to get started with Chef. Ad-hoc remote execution, scans and configuration tasks, cookbook creation tools, as well as robust dependency and testing software all in one easy-to-install package.

## Install Chef Workstation

If you have not installed Chef Workstation, download and install it via https://www.chef.sh.

## Check versions

New ad-hoc commands `chef-run` and ChefDK commands such as `chef` are available via Chef Workstation. Your output may differ if you are running different versions.

```bash
$ chef-run -v
chef-run: 0.1.114

$ chef -v
Chef Development Kit Version: 3.0.36
chef-client version: 14.1.12
delivery version: master (7206afaf4cf29a17d2144bb39c55b7212cfafcc7)
berks version: 7.0.2
kitchen version: 1.21.2
inspec version: 2.1.72
```

## Ad-hoc remote execution with `chef-run`

The `chef-run` utility allows you to execute ad-hoc configuration updates on the systems you manage without needing to first set up a Chef server. With chef-run, you connect to servers over SSH or WinRM, and can apply single resources, recipes, or entire cookbooks directly from your local workstation.


### Example: Installing NTP Server

Chef Workstation combines the power of InSpec and chef-run to give you the ability to easily detect and correct issues on any target instance. A common task that an environment maintainer performs is ensuring that the Network Time Protocol (NTP) is installed, so clocks are kept in sync between servers. InSpec allows us to simply query whether the package is installed via its package resource:

```ruby
describe package('ntp') do
  it { should be_installed }
end
 ```

Chef provides a similar single-resource solution for ensuring the package is installed:

```ruby
package 'ntp' do
  action :install
end
```

Use chef-run, to converge targets against a single resource without needing to create a cookbook or recipe -- run the resource directly from the command-line:

```bash
chef-run myhost package ntp action=install
```

Combined with the InSpec resource to validate whether the package was installed successfully, we have everything we need to define our requirements, and make sure they're met with two simple commands.

![Chef Run NTP Installation](/images/chef-workstation/chef-run.gif)

### Recipe and Multi-Node Convergence

`chef-run` can execute Chef recipes and cookbooks as well, and run against multiple targets in parallel. Here are a few other examples of chef-run in action.

#### Example: Recipe execution on multiple targets

Runs the default recipe from the defined cookbook against myhost1 & myhost2

```bash
chef-run myhost1,myhost2 /path/to/my/cookbook
```

#### Example: Alternate Recipe syntax and targets defined by a range

Runs the `my_cookbook::my_recipe` cookbook against servers myhost1 through myhost20

```bash
chef-run myhost[1:20] my_cookbook::my_recipe
```

#### Further Reading

* [Chef Run CLI Reference](https://chef.sh/docs/reference/chef-run/)
* [Introducing Chef Workstation](https://blog.chef.io/2018/05/23/introducing-chef-workstation/)
* [Chef Workstation - How We Made that Demo](https://blog.chef.io/2018/06/25/chef-workstation-how-we-made-that-demo/)
