+++
title = "knife winrm"
draft = false

gh_repo = "chef-workstation"

[menu]
  [menu.workstation]
    title = "knife winrm"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_winrm.md knife rinrm"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++

## Knife winrm Overview

Use the `knife winrm` subcommand to invoke commands over WinRM (in parallel) on a subset of nodes within an organization, based on the results of a search query made to the Chef Infra Server.

{{< note >}}

Review the list of [common options](/workstation/knife_options/) available to this (and all) knife subcommands and plugins.

{{< /note >}}

### Requirements

This subcommand requires WinRM to be installed, and then configured correctly, including ensuring the correct ports are open. For more information, see Microsoft's documentation on [Windows Remote Management](https://docs.microsoft.com/en-us/windows/desktop/WinRM/installation-and-configuration-for-windows-remote-management).
Use the quick configuration option in WinRM to allow outside connections and the entire network path from knife (and the workstation). Run the following on the Windows target:

```powershell
C:\> winrm quickconfig -q
```

Often commands can take longer than the default `MaxTimeoutms` WinRM configuration setting. Increase this value to `1800000` (30 minutes).

To update this setting, run the following command on the Windows target:

```powershell
C:\> winrm set winrm/config '@{MaxTimeoutms="1800000"}'
```

Ensure that the Windows Firewall is configured to allow WinRM
connections between the workstation and the Chef Infra Server. For example:

```powershell
C:\> netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any
```

### Negotiate, NTLM

When knife is executed from a Microsoft Windows system, it is no longer necessary to make additional configuration of the WinRM listener on the target node to enable successful authentication from the workstation. It is sufficient to have a WinRM listener on the remote node configured to use the default configuration for `winrm quickconfig`. This is because `knife winrm` supports the Microsoft Windows negotiate protocol, including NTLM authentication, which matches the authentication requirements for the default configuration of the WinRM listener.

{{< note >}}

To use Negotiate or NTLM to authenticate as the user specified by the `--winrm-user` option, include the user's Microsoft Windows domain, using the format `domain\user`, where the backslash (`\`) separates the domain from the user.

{{< /note >}}

For example:

``` bash
knife winrm web1.cloudapp.net 'dir' -x 'proddomain\webuser' -P 'password'
```

and:

``` bash
knife winrm db1.cloudapp.net 'dir' -x '.\localadmin' -P 'password'
```

### Domain Authentication

The `knife winrm` subcommand supports Microsoft Windows domain authentication. This requires:

- An SSL certificate on the target node
- The certificate details can be viewed and its [thumbprint hex values copied](https://docs.microsoft.com/en-us/dotnet/framework/wcf/feature-details/how-to-view-certificates-with-the-mmc-snap-in)

To create the listener over HTTPS, run the following command on the Windows target:

```powershell
C:\> winrm create winrm/config/Listener?Address=IP:<ip_address>+Transport=HTTPS @{Hostname="<fqdn>";CertificateThumbprint="<hexidecimal_thumbprint_value>"}
```

where the `CertificateThumbprint` is the thumbprint hex value copied from the certificate details. (The hex value may require that spaces be removed before passing them to the node using the `knife winrm` subcommand.) WinRM 2.0 uses port `5985` for HTTP and port `5986` for HTTPS traffic, by default.

To validate communication with the Windows system using domain authentication run:

``` bash
knife winrm 'node1.domain.com' 'dir' -m -x domain\\administrator -P 'super_secret_password' -p 5986
```

## winrm

Use the `winrm` argument to create a connection to one or more remote machines. As each connection is created, a password must be provided. This argument uses the same syntax as the `search` subcommand.

{{% knife_windows_winrm_ports %}}

### Syntax

This argument has the following syntax:

``` bash
knife winrm SEARCH_QUERY SSH_COMMAND (options)
```

### Options

This argument has the following options:

`-a ATTR`, `--attribute ATTR`

: The attribute used when opening a connection. The default attribute is the FQDN of the host. Other possible values include a public IP address, a private IP address, or a hostname.

`-C NUM`, `--concurrency NUM`

: Changed in knife-windows 1.9.0. The number of allowed concurrent connections. Defaults to 1.

`-f CA_TRUST_FILE`, `--ca-trust-file CA_TRUST_FILE`

: Optional. The certificate authority (CA) trust file used for SSL transport.

`-p PORT`, `--winrm-port PORT`

: The WinRM port. The TCP port on the remote system to which `knife windows` commands that are made using WinRM are sent. Default: `5986` when `--winrm-transport` is set to `ssl`, otherwise `5985`.

`-P PASSWORD`, `--winrm-password PASSWORD`

: The WinRM password.

`-R KERBEROS_REALM`, `--kerberos-realm KERBEROS_REALM`

: Optional. The administrative domain to which a user belongs.

`--returns CODES`

: A comma-delimited list of return codes that indicate the success or failure of the command that was run remotely.

`-S KERBEROS_SERVICE`, `--kerberos-service KERBEROS_SERVICE`

: Optional. The service principal used during Kerberos-based authentication.

`SEARCH_QUERY`

: The search query used to return a list of servers to be accessed using SSH and the specified `SSH_COMMAND`. This option uses the same syntax as the search subcommand.

`SSH_COMMAND`

: The command to be run against the results of a search query.

`--session-timeout MINUTES`

: The amount of time (in minutes) for the maximum length of a WinRM session.

`--ssl-peer-fingerprint FINGERPRINT`

: SSL Cert Fingerprint to bypass normal cert chain checks

`-t TRANSPORT`, `--winrm-transport TRANSPORT`

: The WinRM transport type. Possible values: `ssl` or `plaintext`.

`-T`, `--keytab-file KEYTAB_FILE`

: The keytab file that contains the encryption key required by Kerberos-based authentication.

`--winrm-authentication-protocol PROTOCOL`

: The authentication protocol to be used during WinRM communication. Possible values: `basic`, `kerberos` or `negotiate`. Default value: `negotiate`.

`--winrm-codepage Codepage`

: The codepage to use for the WinRM Command Shell

`--winrm-shell SHELL`

: The WinRM shell type. Valid choices are `cmd`, `powershell` or `elevated`. Default value: `cmd`. The `elevated` shell is similar to the `powershell` option, but runs the powershell command from a scheduled task.

`--winrm-ssl-verify-mode MODE`

: The peer verification mode that is used during WinRM communication. Possible values: `verify_none` or `verify_peer`. Default value: `verify_peer`.

`-x USERNAME`, `--winrm-user USERNAME`

: The WinRM user name.

## Examples

**Find Uptime for Web Servers**

To find the uptime of all web servers, enter:

``` bash
knife winrm "role:web" "net stats srv" -x Administrator -P password
```

**Force a Chef Infra Client run**

To force a Chef Infra Client run:

``` bash
knife winrm 'ec2-50-xx-xx-124.amazonaws.com' 'chef-client -c c:/chef/client.rb' -m -x admin -P 'password'
ec2-50-xx-xx-124.amazonaws.com [date] INFO: Starting Chef Run (Version 0.9.12)
ec2-50-xx-xx-124.amazonaws.com [date] WARN: Node ip-0A502FFB has an empty run list.
ec2-50-xx-xx-124.amazonaws.com [date] INFO: Chef Run complete in 4.383966 seconds
ec2-50-xx-xx-124.amazonaws.com [date] INFO: cleaning the checksum cache
ec2-50-xx-xx-124.amazonaws.com [date] INFO: Running report handlers
ec2-50-xx-xx-124.amazonaws.com [date] INFO: Report handlers complete
```

Where in the examples above, `[date]` represents the date and time the long entry was created. For example:
`[Fri, 04 Mar 2011 22:00:53 +0000]`.
