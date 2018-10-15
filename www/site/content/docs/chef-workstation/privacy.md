+++
title = "Privacy and Telemetry"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "50"
+++

## Chef Workstation Telemetry

Chef Workstation collects information to help us identify bugs and how users
are interacting with Chef Workstation to help us make continuous improvements.

We capture:

* A unique installation-id that is not connected to any customer data. This helps us track
  the number of active Chef Workstation installations without needing to perform
  IP-based tracking.
* The Chef-specific commands you execute, **without** any of the arguments you pass.
* Your host operating system and version.
* A SHA256 sum of any hostname that you're connecting to via `chef-run`.
* How you connect to a remote host via `chef-run`, either WinRM or SSH.
* Target operating system of any hosts connected to via `chef-run`.

## Usage of Your Data

We use this data to track Chef Workstation usage patterns, identify bugs, and
iterate development based on the aggregate feedback it providesa

Only Chef Software, Inc employees have access to your data. We will never sell,
re-sell, or use your data in a malicious manner.

## Opting out

* To stop the capture of telemetry data from a single session, set the
  environment variable `CHEF_TELEMETRY_OPT_OUT` to any value before running
  chef-run, for example:
  ```
  CHEF_TELEMETRY_OPT_OUT=1 chef-run -h
  ```
*  Disable telemetry entirely by adding the following to
   `$HOME/.chef-workstation/config.toml`:

```bash
[telemetry]
enabled=false
```

### What telemetry data does Chef Workstation Capture?

* The Chef specific commands you execute (we do not capture any arguments)
* Connection method (WinRM or SSH)
* Host and Target operating system and version

## See Your Data

You can view the analytics we collect before it is sent. Find--and remove--your
data in the `HOME/.chef-workstation/telemetry/` folder. We save the data from a
current chef-run in the telemetry folder and collect it at the start of the
next chef-run.

When telemetry is disabled, previously collected analytics will not be sent.
