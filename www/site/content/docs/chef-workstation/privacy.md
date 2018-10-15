+++
title = "Privacy and Telemetry"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "50"
+++

## Chef Workstation Telemetry

Chef Workstation collects information to help us identify bugs and how users are interacting with Chef Workstation to help us make continuous improvements.

We capture:

* The Chef-specific commands you execute, **without** any of the arguments you pass.
* How you connect, either WinRM or SSH.
* Your host operating system and version.

## See Your Data

You can view the analytics we collect before it is sent. Find--and remove--your data in the `HOME/.chef-workstation/telemetry/` folder. We save the data from a current chef-run in the telemetry folder and collect it at the start of the next chef-run.

Only Chef Software, Inc employees have access to your data. We will never sell, re-sell, or use your data in a malicious manner.

## Opting out

* To stop the capture of telemetry data from a single session, set the environment variable CHEF_TELEMETRY_OPT_OUT to any value before running chef-run.
*  Disable telemetry entirely by adding the following to `$HOME/.chef-workstation/config.toml`:

```bash
[telemetry]
enabled=false
```
