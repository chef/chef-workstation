+++
title = "Frequently Asked Questions"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight= "100"
+++


#### Is Chef Workstation open source? 

Yes! Our source code is available on [GitHub](https://github.com/chef/chef-workstation). Chef Workstation is open souce software released under the [Apache 2.0 license](https://github.com/chef/chef-workstation/blob/master/LICENSE). 

#### How can I contribute to Chef Workstation?

We always welcome (and deeply appreciate!) new contributions to the project. The best way to start contributing to Chef Workstation during the beta period is to provide us with in-depth feedback by creating GitHub issues or sending your feedback to <beta@chef.io>. 

We are working on guidelines on how to keep development of the project awesome for all contributors. 


#### Operating Systems Supported 


| Platform                         | Version  |
| -------------                    | -----:|
| Apple macOS                      | 10.11, 10.12, 10.13|
| Microsoft Windows                | 10, Server 2008 R2, Server 2012, Server 2012 R2, Server 2016 |
| Red Hat Enterprise Linux         | 6.x, 7.x |
| SUSE Enterprise Linux Server     | 11 SP4, 12 SP1+ |
| Ubuntu                           | 14.04, 16.04, 18.04 |
| Debian                           | 7.x, 8.x, 9.x |
| Scientific Linux                 | 6.x, 7.x |

* Note: Supported platforms and versions for Chef Workstation are subject to change for the duration of the beta program. 

#### Why does Chef Workstation collect usage analytics and bug reports? 

Chef Workstation tracks anonymous errors and analytics to help us understand why things go wrong adn to help us understand how users are interacting with Chef Workstation so we can continously make it better.
##### What we capture? 

- The Chef specific commands you execute (We do **not** capture any arguments)
- Connection method (WinRM or SSH)
- Operating System and version 

##### Who can view it?

You can view the analytics we collect before it is sent. Telemetry from previous run(s) is sent when you start chef-cli. The data can be found in and removed from HOME/.chef-workstation/telemetry/ folder. 

The data collected is only accessible to employees of Chef Software, Inc. and under no circumstances will it be sold/re-sold or used in a malicious manner. 

##### How to opt-out?

- You can stop a single session from being captured by setting the environment variable CHEF_TELEMETRY_OPT_OUT to any value before running chef-cli. 
- You can disable it completely by adding the following to HOME/.chef-workstation/config.toml 

```
[telemetry]
enabled=false
```

