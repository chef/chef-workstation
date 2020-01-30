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

If you have not installed Chef Workstation, <a href="#" data-omnitruck-download="chef-workstation">download</a> and [install]({{< ref "../chef-workstation/install.md#installing" >}}) it.

## Check versions

New ad-hoc commands `chef-run` and Chef CLI commands such as `chef` are available via Chef Workstation. See your installed version of Chef Workstation and Chef tools with `chef -v`. You can also check your Workstation version by selecting "About Chef Workstation" from the Chef Workstation App.

```bash
$ chef -v
Chef Workstation version: 0.15.6
Chef Infra Client version: 15.7.32
Chef InSpec version: 4.18.51
Chef CLI version: 2.0.0
Test Kitchen version: 2.3.4
Cookstyle version: 5.20.0
```

## Ad-hoc remote execution with `chef-run`

The `chef-run` utility allows you to execute ad-hoc configuration updates on the systems you manage without setting up a Chef server. With `chef-run`, you connect to servers over SSH or WinRM, and you can apply single resources, recipes, or even entire cookbooks directly from the command line.

### Example: Installing NTP Server

Chef Workstation combines the power of InSpec and `chef-run`, giving you the ability to easily detect and correct issues on any target instance. One common task that administrators perform in their environments is installing the Network Time Protocol (NTP), which keeps the clocks in sync between servers. InSpec allows us to check if the package is installed with a query, using the InSpec `package` resource:

```ruby
describe package('ntp') do
  it { should be_installed }
end
 ```

Chef also provides a single-resource solution to install the Network Time Protocol package:

```ruby
package 'ntp' do
  action :install
end
```

With `chef-run`, you can run the resource directly from the command-line, converging your targets with a single resource, without creating a cookbook or recipe:

```bash
chef-run myhost package ntp action=install
```

Combined with executing an InSpec scan to validate successful package installation, we have everything we need to define our requirements, and make sure they're met with two simple commands, either locally or remotely.

```ruby
inspec exec ntp-check -t ssh://myuser@myhost -i ~/.ssh/mykey
```

```bash
chef-run -i ~/.ssh/mykey myuser@myhost package ntp action=install
```

![Chef Run NTP Installation](/images/chef-workstation/chef-run.gif)

### Recipe and Multi-Node Convergence

Use `chef-run` to execute Chef recipes and cookbooks as well, and run it against multiple targets in parallel. Here are a few  examples of chef-run in action:

#### Example: Recipe execution on multiple targets

Run the default recipe from the defined cookbook against two resources: myhost1 & myhost2.

```bash
chef-run myhost1,myhost2 /path/to/my/cookbook
```

#### Example: Alternate Recipe syntax and targets defined by a range

Run the `my_cookbook::my_recipe` cookbook against twenty resources: myhost1 through myhost20

```bash
chef-run myhost[1:20] my_cookbook::my_recipe
```

#### Further Reading

* [Chef Run CLI Reference]({{< ref "../reference/chef-run.md" >}})
* [Introducing Chef Workstation](https://blog.chef.io/2018/05/23/introducing-chef-workstation/)
* [Chef Workstation - How We Made that Demo](https://blog.chef.io/2018/06/25/chef-workstation-how-we-made-that-demo/)
