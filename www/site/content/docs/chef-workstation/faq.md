+++
title = "Frequently Asked Questions"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight= "30"
+++

#### Is Chef Workstation open source?

Yes! Our source code is available on [GitHub](https://github.com/chef/chef-workstation). Chef Workstation is open source software released under the [Apache 2.0 license](https://github.com/chef/chef-workstation/blob/master/LICENSE).

#### How can I contribute to Chef Workstation?

We always welcome (and deeply appreciate!) new contributions to the project. The best way to start contributing to Chef Workstation during the beta period is to provide us with in-depth feedback by creating GitHub issues or sending your feedback to <beta@chef.io>.

We are working on guidelines on how to keep development of the project awesome for all contributors.

#### Operating Systems Supported

Supported Host Operating Systems:

| Platform                         | Version  |
| -------------                    | -----:|
| Apple macOS                      | 10.11, 10.12, 10.13|
| Microsoft Windows                | 10, Server 2008 R2, Server 2012, Server 2012 R2, Server 2016 |
| Red Hat Enterprise Linux / CentOS| 6.x, 7.x |
| SUSE Enterprise Linux Server     | 11 SP4, 12 SP1+ |
| Ubuntu                           | 14.04, 16.04, 18.04 |
| Debian                           | 7.x, 8.x, 9.x |

Supported Target Operating Systems:

| Platform                         | Version  |
| -------------                    | -----:|
| Microsoft Windows                | 10, Server 2008 R2, Server 2012, Server 2012 R2, Server 2016 |
| Red Hat Enterprise Linux         | 6.x, 7.x |
| SUSE Enterprise Linux Server     | 11 SP4, 12 SP1+ |
| Ubuntu                           | 14.04, 16.04, 18.04 |
| Debian                           | 7.x, 8.x, 9.x |

* Note: Supported platforms and versions for Chef Workstation are subject to change for the duration of the beta program.

#### Why does Chef Workstation collect usage analytics and bug reports?

Chef Workstation collects information to help us identify bugs and how users are interacting with Chef Workstation to help us make continuous improvements.

##### What does Chef Workstation capture?

* The Chef specific commands you execute (We do **not** capture any arguments)
* Connection method (WinRM or SSH)
* Host Operating System and version

##### Who can view it?

You can view the analytics we collect before it is sent. Telemetry from previous run(s) is sent when you start chef-cli. Find--and remove it, your data--from the `HOME/.chef-workstation/telemetry/` folder.

Your data collected is only accessible to employees of Chef Software, Inc. We will never sell, re-sell, or use your data in a malicious manner.

##### How to opt-out?

* You can stop a single session from being captured by setting the environment variable CHEF_TELEMETRY_OPT_OUT to any value before running chef-cli.
* You can disable telemetry by adding the following to `$HOME/.chef-workstation/config.toml`

```bash
[telemetry]
enabled=false
```
