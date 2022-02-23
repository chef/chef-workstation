+++
title = "knife user"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_user.html", "/knife_user/"]

[menu]
  [menu.workstation]
    title = "knife user"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_user.md knife user"
    parent = "chef_workstation/chef_workstation_tools/knife"
+++
<!-- markdownlint-disable-file MD024 MD036 -->

{{% knife_user_summary %}}

{{< note >}}

{{% knife_common_see_common_options_link %}}

{{< /note >}}

## create

Use the `create` argument to create a user. This process will generate
an RSA key pair for the named user. The public key will be stored on the
Chef Infra Server and the private key will be displayed on `STDOUT` or
written to a named file.

- For the user, the private key should be copied to the system as `/etc/chef/client.pem`.
- For knife, the private key is typically copied to `~/.chef/client_name.pem` and referenced in the config.rb configuration file.

### Syntax

This argument has the following syntax:

``` bash
knife user create USERNAME DISPLAY_NAME FIRST_NAME LAST_NAME EMAIL PASSWORD (options)
```

### Options

This argument has the following options:

`-f FILE`, `--file FILE`

: Save a private key to the specified file name.

`--password PASSWORD`

: The user password.

`--user-key FILENAME`

: The path to a file that contains the public key. If this option is not specified, the Chef Infra Server will generate a public/private key pair.

`-k`, `--prevent-keygen`

:Prevent Chef Infra Server from generating a default key pair for you. Cannot be passed with --user-key.

`-o ORGNAME` `--orgname ORGNAME`

:Associate new user to an organization matching ORGNAME

`--first-name FIRST_NAME`

:First name for the user

`--last-name LAST_NAME`

:Last name for the user

`--email EMAIL`

:Email for the user

`--prompt-for-password`, `-p`

:Prompt for user password

{{< note >}}

{{% knife_common_see_all_config_options %}}

{{< /note >}}

### Examples

The following examples show how to use this knife subcommand:

**Create a user**

``` bash
knife user create tbucatar "Tamira Bucatar" tbucatar@example.com -f /keys/tbucatar
```

``` bash
knife user create arno arno schmidt arno@chef.io password
-----BEGIN RSA PRIVATE KEY-----
[...]
-----END RSA PRIVATE KEY-----
```

## delete

Use the `delete` argument to delete a registered user.

### Syntax

This argument has the following syntax:

``` bash
knife user delete USER_NAME
```

### Options

`--no-disassociate-user`, `-d`

:Don't disassociate the user first

`"--remove-from-admin-groups`, `-R`

:If the user is a member of any org admin groups, attempt to remove from those groups. Ignored if --no-disassociate-user is set.

### Examples

The following examples show how to use this knife subcommand:

**Delete a user**

``` bash
knife user delete "Arjun Koch"
```

## edit

Use the `edit` argument to edit the details of a user. When this
argument is run, knife will open \$EDITOR. When finished, knife will
update the Chef Infra Server with those changes.

### Syntax

This argument has the following syntax:

``` bash
knife user edit USER_NAME
```

### Options

`--input FILENAME`, `-i FILENAME`

:Name of file to use for PUT or POST

`--filename FILENAME`, `-f FILENAME`

:Write private key to FILENAME rather than STDOUT

### Examples

``` bash
EDITOR=ed knife user edit arno
639
1,%p
{
  "username": "arno",
  "email": "arno@chef.io",
  "display_name": "arno schmidt",
  "first_name": "arno",
  "last_name": "schmidt",
  "middle_name": "",
  "public_key": "-----BEGIN PUBLIC KEY-----\n[...]\n-----END PUBLIC KEY-----\n\n"
}
/email/s/chef.io/opscode.com/p
"email": "arno@opscode.com",
wq
643
Saved arno.

knife  user show arno
display_name:  arno schmidt
email:         arno@opscode.io
first_name:     arno
last_name:     schmidt
middle_name:
public_key: -----BEGIN PUBLIC KEY-----
[...]
-----END PUBLIC KEY-----


username:   arno
```

## list

Use the `list` argument to show list of all registered users.

### Syntax

This argument has the following syntax:

``` bash
knife user list
```

### Options

`-w`, `--with-uri`,

:Show corresponding URIs.

### Examples

The following examples show how to use this knife subcommand:

``` bash
knife user list
alice
pivotal

knife user list -w
alice: https://chef-server.fqdn/users/alice
pivotal: https://chef-server.fqdn/users/pivotal

knife org list -w -a
acme: https://chef-server.fqdn/organizations/acme
```

## password

Command for managing password and authentication for a user.

### Syntax

This argument has the following syntax:

``` bash
knife user password USER_NAME [PASSWORD | ]
```

### Options

`--enable_external_auth`,

:Enable external authentication for this user (such as LDAP).

### Examples

The following examples show how to use this knife subcommand:

``` bash
knife user password arno newpassword
{"username"=>"arno", "email"=>"arno@opscode.com", "display_name"=>"arno schmidt", "first_name"=>"arno", "last_name"=>"schmidt", "middle_name"=>"", "public_key"=>"-----BEGIN PUBLIC KEY-----\n[...]\n-----END PUBLIC KEY-----\n\n", "password"=>"newpassword", "recovery_authentication_enabled"=>true}
Authentication info updated for arno.
```

## key create

Use the `key create` argument to create a public key.

### Syntax

This argument has the following syntax:

``` bash
knife user key create USER_NAME (options)
```

### Options

This argument has the following options:

`-e DATE`, `--expiration-date DATE`

: The expiration date for the public key, specified as an ISO 8601 formatted string: `YYYY-MM-DDTHH:MM:SSZ`. If this option is not specified, the public key will not have an expiration date. For example: `2013-12-24T21:00:00Z`.

`-f FILE`, `--file FILE`

: Save a private key to the specified file name.

`-k NAME`, `--key-name NAME`

: The name of the public key.

`-p FILE_NAME`, `--public-key FILE_NAME`

: The path to a file that contains the public key. If this option is not specified, and only if `--key-name` is specified, the Chef Infra Server will generate a public/private key pair.

### Examples

None.

## key delete

Use the `key delete` argument to delete a public key.

### Syntax

This argument has the following syntax:

``` bash
knife user key delete USER_NAME KEY_NAME
```

### Examples

None.

## key edit

Use the `key edit` argument to modify or rename a public key.

### Syntax

This argument has the following syntax:

``` bash
knife user key edit USER_NAME KEY_NAME (options)
```

### Options

This argument has the following options:

`-c`, `--create-key`

: Generate a new public/private key pair and replace an existing public key with the newly-generated public key. To replace the public key with an existing public key, use `--public-key` instead.

`-e DATE`, `--expiration-date DATE`

: The expiration date for the public key, specified as an ISO 8601 formatted string: `YYYY-MM-DDTHH:MM:SSZ`. If this option is not specified, the public key will not have an expiration date. For example: `2013-12-24T21:00:00Z`.

`-f FILE`, `--file FILE`

: Save a private key to the specified file name. If the `--public-key` option is not specified the Chef Infra Server will generate a private key.

`-k NAME`, `--key-name NAME`

: The name of the public key.

`-p FILE_NAME`, `--public-key FILE_NAME`

: The path to a file that contains the public key. If this option is not specified, and only if `--key-name` is specified, the Chef Infra Server will generate a public/private key pair.

### Examples

None.

## key list

Use the `key list` argument to view a list of public keys for the named
user.

### Syntax

This argument has the following syntax:

``` bash
knife user key list USER_NAME (options)
```

### Options

This argument has the following options:

`-e`, `--only-expired`

: Show a list of public keys that have expired.

`-n`, `--only-non-expired`

: Show a list of public keys that have not expired.

`-w`, `--with-details`

: Show a list of public keys, including URIs and expiration status.

### Examples

None.

## key show

Use the `key show` argument to view details for a specific public key.

### Syntax

This argument has the following syntax:

``` bash
knife user key show USER_NAME KEY_NAME
```

### Examples

None.

## list

Use the `list` argument to view a list of registered users.

### Syntax

This argument has the following syntax:

``` bash
knife user list (options)
```

### Options

This argument has the following options:

`-w`, `--with-uri`

: Show the corresponding URIs.

### Examples

None.

## reregister

Use the `reregister` argument to regenerate an RSA key pair for a user.
The public key will be stored on the Chef Infra Server and the private
key will be displayed on `STDOUT` or written to a named file.

{{< note >}}

Running this argument will invalidate the previous RSA key pair, making
it unusable during authentication to the Chef Infra Server.

{{< /note >}}

### Syntax

This argument has the following syntax:

``` bash
knife user reregister USER_NAME (options)
```

### Options

This argument has the following options:

`-f FILE_NAME`, `--file FILE_NAME`

: Save a private key to the specified file name.

{{< note >}}

{{% knife_common_see_all_config_options %}}

{{< /note >}}

### Examples

The following examples show how to use this knife subcommand:

**Regenerate the RSA key-pair**

``` bash
knife user reregister "Arjun Koch"
```

## show

Use the `show` argument to show the details of a user.

### Syntax

This argument has the following syntax:

``` bash
knife user show USER_NAME (options)
```

### Options

This argument has the following options:

`--with-orgs`, `-l`

: Show the organizations of which the user is a member.

### Examples

The following examples show how to use this knife subcommand:

**Show user data**

To view a user named `Tamira Bucatar`, enter:

``` bash
knife user show "Tamira Bucatar"
```

to return something like:

``` bash
chef_type: user
json_class:  Chef::User
name:        Tamira Bucatar
public_key:
```

``` bash
knife user show alice -l
display_name:  Alice Schmidt
email:       alice@chef.io
first_name:  Alice
last_name:   Schmidt
middle_name:
organizations: acme
public_key:  -----BEGIN PUBLIC KEY-----
[...]
-----END PUBLIC KEY-----


username:   alice
```

**Show user data as JSON**

To view information in JSON format, use the `-F` common option as part
of the command like this:

``` bash
knife user show "Tamira Bucatar" -F json
```

(Other formats available include `text`, `yaml`, and `pp`, e.g.
`-F yaml` for YAML.)
