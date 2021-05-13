+++
title = "Setting up Knife"
draft = false

gh_repo = "chef-workstation"

aliases = ["/knife_setup.html", "/knife_setup/"]

[menu]
  [menu.workstation]
    title = "Setting up Knife"
    identifier = "chef_workstation/chef_workstation_tools/knife/knife_setup.md Setting up Knife"
    parent = "chef_workstation/chef_workstation_tools/knife"
    weight = 20
+++

knife is a command-line tool that provides an interface between a local chef-repo and the Chef Infra Server. The knife command line tool must be configured to communicate with the Chef Infra Server as well as any other infrastructure within your organization.

The first time you set up Chef Infra, you need to manually create the directory for important Chef Infra files, such as `config.rb`.

We recommend setting up knife to use profiles. Knife profiles let you use knife with more than one Chef Infra Server and with more than one organization on a Chef Infra Server.

To use knife profiles, the first time you set up your workstation enter:

```bash
mkdir ~/.chef
touch ~/.chef/credentials
```

```powershell
New-Item -Path "c:\" -Name ".chef" -ItemType "directory"
New-Item -ItemType "file" -Path "c:\.chef\credentials"
```

Previous Chef Infra setups recommended setting up knife with a `config.rb` file. Configuring knife with `config.rb` is still valid, but only for working on one Chef Infra Server with one Chef Infra Server organization.

```bash
mkdir ~/.chef
touch ~/.chef/config.rb
```

```powershell
New-Item -Path "c:\" -Name ".chef" -ItemType "directory"
New-Item -ItemType "file" -Path "c:\.chef\config.rb"
```

{{% chef_repo_many_users_same_knife %}}

**Profile Support since Chef 13.7**

Knife profiles make switching knife between Chef Infra Servers or between organizations on the same Chef Infra Server easier. Knife profiles are an alternative to `config.rb`--you cannot use both.

Set up knife profiles by adding them to the `.chef/credentials` file in your home directory on your workstation. The `credentials` file is TOML formatted. Each profile is listed as a separate 'table' name of your choice, and is followed by `key = value` pairs. The keys correspond to any setting permitted in the [config.rb](/workstation/config_rb/) file.

File paths, such as `client_key` or `validator_key`, are relative to `~/.chef` unless you provide absolute path. Identifiy clients with `client_name` (preferred) or `node_name`.

Store credentials for use with target mode (`chef-client --target switch.example.org`) as a separate profile in the credentials file. Use the DNS name of the target as the profile name and surrounded by single
quotes when the name contains a period. For example:
`['switch.example.org']`. Keys that are valid configuration options get passed to train, such as `port`.

``` none
# Example .chef/credentials file
[default]
client_name = "barney"
client_key = "barney_rubble.pem"
chef_server_url = "https://api.chef.io/organizations/bedrock"

# a 'config context' such as knife can be is configured as a separate table
[default.knife]
ssh_user = 'ubuntu' # this would have been knife[:ssh_user] in your config.rb
aws_profile = 'engineering'
use_sudo = true

# a client_key may also be specified inline as in this example
[dev]
client_name = "admin"
client_key = """
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCqGKukO1De7zhZj6EXAMPLEKEY
...ABC123=
-----END RSA PRIVATE KEY-----
"""
validator_key = "test-validator.pem"
chef_server_url = "https://api.chef-server.dev/organizations/test"

['web.preprod']
client_name = "brubble"
client_key = "preprod-brubble.pem"
chef_server_url = "https://preprod.chef-server.dev/organizations/preprod"

['switch.example.org']
user = "cisco"
password = "cisco"
enable_password = "cisco"
```

There are four ways to select which profile to use and are listed in
priority order:

1. Pass the `--profile` option to knife, e.g. `knife node list --profile dev`.
2. Set the profile name in the `CHEF_PROFILE` environment variable.
3. Write the profile name to the `~/.chef/context` file.
4. Otherwise, knife uses the 'default' profile.

## Knife Config

**knife config support since Chef 14.4**

Use the `knife config` command to manage your knife profiles.

List your profiles with the `knife config list-profiles` command.

For example:

```
knife config list-profiles
```

Returns something like:

``` bash
## Profile              Client   Key                          Server
 default             barney   ~/.chef/barney_rubble.pem    https://api.chef.io/organizations/bedrock
 dev                 admin    ~/.chef/admin.pem            https://api.chef-server.dev/organizations/test
 web.preprod         brubble  ~/.chef/preprod-brubble.pem  https://preprod.chef-server.dev/organizations/preprod
 switch.example.org  btm      ~/.chef/btm.pem              https://localhost:443
```

The line that begins with the asterisk is the currently selected profile. To change the current profile, run the `knife config use-profile NAME` command, which will write the profile name to the `~/.chef/context` file.

Running `knife config get-profile` prints out the name of the currently selected profile.

If you need to troubleshoot any settings, you can verify the value that knife is using with the `knife config get KEY` command, for example:

``` bash
knife config get chef_server_url
Loading from credentials file /home/barney/.chef/credentials
chef_server_url: https://api.chef-server.dev/organizations/test
```

## config.rb Configuration File

The `config.rb`  file contains settings for the knife command-line tool and any
installed knife plugins.
See the [config.rb documentation](/workstation/config_rb/) for a complete list of configuration options.

### Load Path Priority

The config.rb file loads every time the knife command is invoked using the following load order:

- From a specified location given the `--config` flag
- From a specified location given the `$KNIFE_HOME` environment variable, if set
- From a `config.rb` file within the current working directory, e.g., `./config.rb`
- From a `config.rb` file within a `.chef` directory in the current working directory, e.g., `./.chef/config.rb`
- From a `config.rb` file within a `.chef` directory located one directory above the current working directory, e.g., `../.chef/config.rb`
- From `~/.chef/config.rb` (macOS and Linux platforms) or `c:\Users\<username>\.chef` (Microsoft Windows platform)

{{< note >}}

On Microsoft Windows, the `config.rb` file is located at: `%HOMEDRIVE%:%HOMEPATH%\.chef` (e.g. `c:\Users\<username>\.chef`).
In a script for Microsoft Windows, use: `%USERPROFILE%\chef-repo\.chef`.

{{< /note >}}

### config.rb Configuration Within a Chef Repository

Use <span class="title-ref">knife configure</span> command to generate your initial `config.rb` file in your home directory.
See [knife configure](/workstation/knife_configure/) for details.

## Setting Your Text Editor

Some knife commands, such as `knife data bag edit`, require that information be edited as JSON data using a text editor. For example, the following command:

``` bash
knife data bag edit admins admin_name
```

opens up the text editor with data similar to:

``` javascript
{
  "id": "admin_name"
}
```

Then make changes to that file:

``` javascript
{
  "id": "Justin C."
  "description": "I am passing the time by letting time pass over me ..."
}
```

The type of text editor that is used by knife can be configured by adding an entry to your config.rb file, or by setting an `EDITOR` environment variable. For example, to configure knife to open the `vim` text editor, add the following to your config.rb file:

``` ruby
knife[:editor] = "/usr/bin/vim"
```

When a Microsoft Windows file path is enclosed in a double-quoted string (" "), the same backslash character (`\`) that is used to define the file path separator is also used in Ruby to define an escape character. The config.rb file is a Ruby file; therefore, file path separators must be escaped. In addition, spaces in the file path must be replaced with `~1` so that the length of each section within the file path is not more than 8 characters. For example, if EditPad Pro is the text editor of choice and is located at the following path:

```powershell
C:\\Program Files (x86)\EditPad Pro\EditPad.exe
```

the setting in the config.rb file would be similar to:

``` ruby
knife[:editor] = "C:\\Progra~1\\EditPa~1\\EditPad.exe"
```

One approach to working around the double- vs. single-quote issue is to
put the single-quotes outside of the double-quotes. For example, for
Notepad++:

``` ruby
knife[:editor] = '"C:\Program Files (x86)\Notepad++\notepad++.exe" -nosession -multiInst'
```

for Sublime Text:

``` ruby
knife[:editor] = '"C:\Program Files\Sublime Text 2\sublime_text.exe" --wait'
```

for TextPad:

``` ruby
knife[:editor] = '"C:\Program Files (x86)\TextPad 7\TextPad.exe"'
```

and for vim:

``` ruby
knife[:editor] = '"C:\Program Files (x86)\vim\vim74\gvim.exe"'
```

### Using Quotes
 The text editor command cannot include spaces that are not properly wrapped in quotes. The command can be entered with double quotes (" ") or single quotes (' '), but this should be done consistently as shown in the examples above.
