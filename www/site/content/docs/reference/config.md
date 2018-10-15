+++
title = "configuration"
linkTitle = "configuration"
[menu]
  [menu.docs]
    parent = "Reference"
    weight = "10"
+++

# Configuration

Chef Workstation App and `chef-run` configuration is managed in `config.toml`.
If it doesn't exist, it will be created the first time you use `chef-run`. For configuration of
other included tools, reference their respective pages found in
the [ChefDK documentation](https://docs.chef.io/about_chefdk.html).

## Default location

### Windows
  * Powershell: `$env:USERPROFILE\.chef-workstation\config.toml`
  * cmd.exe: `%USERPROFILE%\.chef-workstation\config.toml`

### Linux and Mac
`/home/$USER/.chef-workstation/config.toml`

## Settings

### [telemetry]

Configure telemetry behaviors for Chef Workstation components.

#### Example

```
[telemetry]
enable=true
dev=false
```

#### Option: `enable`
  * Description: When `true`, anonymous usage data and bug reports are sent to Chef.
  * Default: `true`
  * Valid values: `true`, `false`
  * Environment:
    * `CHEF_TELEMETRY_OPT_OUT`: when set to any value, `chef-run` will not capture or send telemetry data.
  * Notes:
    * See Chef's [Privacy Statement](https://www.chef.sh/docs/chef-workstation/privacy/) for the type and usage of gathered data.
  * Used by: `chef-run`

#### Option: `dev`
  * Description: When this and `enable` are true, anonymous data is reported to Chef's QA environment.
  * Default: `false`
  * Valid values: `true`, `false`
  * Used by: `chef-run`, `Chef Workstation App`
  * Notes:
    * Only set this if you have access to Chef's internal QA environment - otherwise the telemetry data will not be successfully captured by Chef.

### [log]

Control logging level and location.

#### Example

```
[log]
level="debug"
location="C:\Users\jdoe\chef-workstation.log"
```

#### Option: `level`
  * Description: determines what kind of messages are logged from locally-run Chef Workstation commands to the to the local log file.
  * Default: `"warn"`
  * Valid values: `"debug"`, `"warn"`, `"info"`, `"error"`, `"fatal"`
  * Used by: `chef-run`

#### Option: `location`
  * Description: The location of the local Chef Workstation log file.
  * Default: `"$USERHOME/.chef-workstation/logs/default.log"`
  * Valid values: Value must be a valid, writable file path.
  * Used by: `chef-run`

### [cache]
Configure caching options.

#### Example

```
[cache]
path="/home/users/jdoe/.cache/chef-workstation"
```

#### Option: `path`
  * Description: The base path used to store cached cookbooks and downloads.
  * Default: `$USERHOME/.chef-workstation/cache`
  * Valid values: This must reference a valid, writable directory.
  * Used by: `chef-run`


### [connection]
Control default connection behaviors.

#### Example

```
[connection]
default_protocol="winrm"
default_user="jdoe"
```

#### Option: `default_protocol`
  * Description: Default protocol for connecting to target hosts.
  * Default: `"ssh"`
  * Valid values: `"ssh"`, `"winrm"`
  * CLI flag: `--protocol PROTO`
  * Used by: `chef-run`

#### Option: `default_user`
  * Description: Default username for target host authentication
  * Default: `root` (Linux),  `administrator` (Windows)
  * Valid values: A username that exists on the target hosts.
  * CLI flag: `--user USERNAME`
  * Used by: `chef-run`

### [connection.winrm]
Control connection behaviors for the WinRM protocol.

#### Example

```
[connection.winrm]
ssl=true
ssl_verify=false
```

#### Option: `ssl`
  * Description: Enable SSL for WinRM session encryption
  * Default: `false`
  * Valid values: `true`, `false`
  * CLI flag: `--[no]-ssl`
  * Used by: `chef-run`

#### Option: `ssl_verify`
  * Description:
  * Default: `true`
  * Valid values: `true`, `false`
  * CLI flag: --ssl-[no]-verify
  * Used by: `chef-run`
  * Notes: Intended for use in testing environments that use self-signed certificates on Windows nodes.

### [chef]

Configure how chef is run remotely.

#### Example

```
[chef]
trusted_certs_dir="/home/jdoe/mytrustedcerts"
cookbook_repo_paths = [
  "/home/jdoe/cookbooks",
  "/var/chef/cookbooks"
]
```

#### Option: `trusted_certs_dir`
  * Description: Describes where to find Chef's trusted certificates. Used to ensure trusted certs are provided to the `chef-client` run on target nodes.
  * Default:  Look first for `.chef/config.rb` and use that value if provided; otherwise `"/opt/chef-workstation/embedded/ssl/certs/"`
  * Valid values: A directory containing the trusted certificates for use in the Chef ecosystem.
  * Used by: `chef-run`

#### Option: `cookbook_repo_paths`
  * Description: Path or paths to use for cookbook resolution.
  * Default: `cookbook_path` value from `.chef/config.rb`, otherwise not fou
  * Valid values: A string referencing a valid cookbook path, or an array of such strings.  See example for syntax.
  * CLI flag: `--cookbook-repo-paths PATH1,PATH2,..PATHn`
  * Used by: `chef-run`
  * Notes:
    * When multiple cookbook paths are provided and a cookbook exists in more than one of them, the cookbook found in the last-most directory will be used. Considering the example, when resolving cookbook `mycb`: if `mycb` existed in both `/home/jdoe/cookbooks` and `/var/chef/cookbooks`, `mycb` in `/var/chef/cookbooks` will be used.
    * See [link and desc here] for more details around how cookbook path is determined.

### [updates]

Control the behavior of automatic update checking for Chef Workstation.

#### Example
```
[updates]
enable=true
channel="current"
```

#### Option: `enable`
  * Description: Enable update checking for Chef Workstation updates.
  * Default: `true`
  * Valid values: `true`, `false`
  * Used by: Chef Workstation App

#### Option: `channel`
  * Description: Set the update channel to use when checking for Chef Workstation updates
  * Default: `"stable"`
  * Valid values: `"stable"`, `"current"`
  * Used by: Chef Workstation App
  * Notes: `"stable"` is the recommended value. Switch to `"current"` is not guaranteed to be stable, and should only be used if you are comfortable with the risks associated.

### [data_collector]
Configure reporting of `chef-client` runs triggered via `chef-run`.

#### Example
```
[data_collector]
url="https://1.1.1.1/data-collector/v0/"
token="ABCDEF0123456789"
```

#### Option: `url`
  * Description: URL of an Automate [data collection](https://automate.chef.io/docs/data-collection/) endpoint.  This URL is provided to the target host, allowing them to report in to Automate when `chef-run` is used to converge the targets.
  * Default: not set
  * Valid values: A valid automate data collector endpoint.
  * Used by: `chef-run`
  * Notes: A valid token generated by automate is required.

#### Option: `token`
  * Description: An Automate [API token](https://automate.chef.io/docs/api-tokens/#creating-a-standard-api-token), used on target host to authenticate to the `url` provided.
  * Default: not set
  * Valid values: A valid token generated by Automate.
  * Used by: `chef-run`
  * Notes:

### [dev]

These options are intended for development and troubleshooting of Chef Workstation tools. Their usage is not supported and is subject to change.

#### Example

```
[dev]
spinner=false
```

#### Option: `spinner`

  * Description: Use animated spinners and progress indicators in the terminal output
  * Default: `true`
  * Valid Values: `true`, `false`
  * Used by: `chef-run`
