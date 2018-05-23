+++
title = "Privacy"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "50"
+++

#### Why does Chef Workstation collect usage analytics and bug reports?

Chef Workstation collects information to help us identify bugs and how users are interacting with Chef Workstation to help us make continuous improvements.

##### What we capture?

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
