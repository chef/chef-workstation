+++
title = "Troubleshooting"
draft = false

gh_repo = "chef-workstation"

[menu]
  [menu.workstation]
    title = "Troubleshooting"
    identifier = "chef_workstation/troubleshooting.md Troubleshooting"
    parent = "chef_workstation"
    weight = 50
+++

## Chef Workstation Logs

Chef Workstation logs are stored in `~/.chef-workstation/logs`.

## Uninstall instructions

Follow the steps provided under [Uninstalling]({{< ref "install_workstation.md#uninstalling" >}}).

## Trusted Certs
We recommend developing the habit of restarting Chef Workstation Powershell after adding certificates to the `trusted_certs` directory on Windows machines.
Sometimes certificate-related commands such as `knife ssl check` don't return the expected results after adding a certificate with `knife ssh fetch`. If this happens:

1. Exit the Chef Workstation Powershell.
1. Select the Chef Workstation Powershell icon to restart.
1. Retry the command.


## Common Error Codes

### CHEFINT001

```txt
CHEFINT001

An remote error has occurred:

  Your SSH Agent has no keys added, and you have not specified a password or a key file.
```

This error now appears as CHEFTRN007. If you're running an older version of chef-run
it will appear as CHEFINT001 with the message above. Follow the steps detailed under
CHEFTRN007 below to resolve.

### CHEFTRN007

`No authentication methods available`

This error occurs when there are no available ssh authentication methods to provide to the server.
chef-run requires a password, a key file, or a `.ssh/config` host entry containing a KeyFile.
Information about each option is below.

#### resolve via chef-run flags

Use `--password` to provide the password required to authenticate to the host:

```bash
chef-run --password $PASSWORD myhost.example.com --password
```

Alternatively, explicitly provide an identity file using '--identity-file':

```bash
chef-run --identity-file /path/to/your/ssh/key
```

#### resolve by adding key(s) to ssh-agent

```bash
## ensure ssh-agent is running. This may report it is already started:
$ ssh-agent

## Add your key file(s):
$ ssh-add
Identity added: /home/timmy/.ssh/id_rsa (/home/timmy/.ssh/id_rsa)
```

### resolve by adding a host entry to ~/.ssh/config

Add an entry for this host to your .ssh/config:

```txt
host example.com
  IdentityFile /path/to/valid/key
```
