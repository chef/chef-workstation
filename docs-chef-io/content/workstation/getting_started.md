+++
title = "Getting Started"
draft = false

gh_repo = "chef-workstation"

aliases = ["/workstation_setup.html", "/chefdk_setup.html", "/workstation.html", "/workstation_setup/"]

[menu]
  [menu.workstation]
    title = "Setup"
    identifier = "chef_workstation/getting_started.md Setup Chef Workstation"
    parent = "chef_workstation"
    weight = 30
+++

This guide walks your through the four parts to set up Chef Workstation on your computer.

* [Configure Ruby Environment]({{< relref "#configure-ruby-environment" >}})
* [Set up your chef-repo]({{< relref "#setup-your-chef-repo" >}}) for storing your cookbooks
* [Setup Chef Credentials]({{< relref "#setup-chef-credentials" >}})
* [Set Up Chef Infra Communication]({{< relref "#setup-tlsssl" >}})
* [Verify Client-to-Server Communication]({{< relref "#Verify Client-to-Server Communication" >}})

## Prerequisites

1. [Download and install Chef Workstation]({{< relref "install_workstation.md" >}})
1. A running instance of [Chef Infra Server]({{< relref "server/install_server.md" >}}) or [Hosted Chef Server](https://manage.chef.io/signup) and access to the:
   1. `USER.pem`

## Configure Ruby Environment

For many users, Ruby is primarily used for developing Chef policy (for example, cookbooks, Policyfiles, and Chef InSpec profiles). If that's true for you, then we recommend using the Chef Workstation Ruby as your default system Ruby. If you use Ruby for software development, we recommend adding Chef Workstation to your shell's PATH variable instead.

{{< note >}}

These instructions are intended for macOS and Linux users. On Windows, Chef Workstation includes a desktop shortcut to a PowerShell prompt already configured for use.

{{< /note >}}

<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="sys-ruby" tab-text="Set System Ruby">}}
{{< foundation_tab panel-link="path-ruby" tab-text="Set $PATH Variable" >}}
{{< /foundation_tabs >}}
<!----End Tabs --->

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="sys-ruby" >}}

1. Open a terminal and enter the following:

    ``` bash
    which ruby
    ```

    which will return something like `/usr/bin/ruby`.

1. To use Chef Workstation-provided Ruby as the default Ruby on your system, edit the `$PATH` and `GEM` environment variables to include paths to Chef Workstation. For example, on a machine that runs Bash, run:

    ``` bash
    echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
    ```

    where `bash` and `~/.bashrc` represents the name of the shell.

    If zsh is your preferred shell then run:

    ``` bash
    echo 'eval "$(chef shell-init zsh)"' >> ~/.zshrc
    ```

    If Fish is your preferred shell then run:

    ``` bash
    echo 'eval (chef shell-init fish)' >> ~/.config/fish/config.fish
    ```

1. Run `which ruby` again. It should return `/opt/chef-workstation/embedded/bin/ruby`.

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="path-ruby" >}}
In a command window, type the following:

``` bash
echo 'export PATH="/opt/chef-workstation/embedded/bin:/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.configuration_file && source ~/.configuration_file
```

where `configuration_file` is the name of the configuration file for the specific command shell. For example, if Bash were the command shell and the configuration file were named `.bashrc`, the command would look something like:

``` bash
export PATH="/opt/chef-workstation/bin:/opt/chef-workstation/embedded/bin:$PATH" >> ~/.bashrc && source ~/.bashrc
```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}
<!----End Panels --->

## Setup Your Chef Repo

If you're setting up Chef for the very first time **in your organization**, then you will need a Chef Infra repository for saving your cookbooks and other work.

{{% chef_repo_description %}}

Use the [chef generate repo]({{< relref "ctl_chef.md#chef-generate-repo" >}}) command to create your Chef Infra repository. For example, to create a repository called `chef-repo`:

``` bash
chef generate repo chef-repo
```

## Setup Chef Credentials

The first time you run the Chef Workstation app, it creates a `.chef` directory in your user directory. The `.chef` directory is where you will store your Chef Workstation configuration and your client keys.

{{< note >}}
If you're setting up Chef Workstation **as a Chef Infra Server administrator**, then you will need to manage users with the [Chef Infra Server CLI](https://docs.chef.io/server/ctl_chef_server/#user-management) or the Manage UI. When you create a new user, a user-specific RSA client key will be generated, which you then need to share securely with that user.
{{</ note >}}

If you're setting up Chef Workstation **as a Chef user**, then you will need to setup your unique client certificate that corresponds to a client on the Chef Infra Server that your server administrator creates for you. The client certificate is an RSA private key in the `.pem` format.

Save your client certificate in the `.chef` directory using the same name as the client created by your server administrator.

### Configure Your User Credentials File

Your `.chef` directory contains an example client `credentials` file, which you can modify to setup communication with your Chef Infra Server.

At a minimum, you must update the following settings with the appropriate values:

- `client_name`: the client name your server administrator created for you
- `client_key`: the path to the client key in your `.chef` directory
- `chef_server_url`: the full URL to your Chef Infra Server including the org

See the [knife config.rb documentation](/workstation/config_rb/) for more details.

<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="credentials-example" tab-text="Example credentials file">}}
{{< foundation_tab panel-link="credentials-demo" tab-text="Completed credentials file" >}}
{{< /foundation_tabs >}}
<!----End Tabs --->

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="credentials-example" >}}

```bash
# This is the Chef Infra credentials file used by the knife CLI and other tools
# This file supports defining multiple credentials profiles, to allow you to switch between users, orgs, and Chef Infra Servers.

# Example credential file configuration:
# [default]
# client_name = 'MY_USERNAME'
# client_key = '/Users/USERNAME/.chef/MY_USERNAME.pem'
# chef_server_url = 'https://api.chef.io/organizations/MY_ORG'
```

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="config-rb-demo" >}}

```bash
# Example completed credential file configuration:
[default]
client_name = 'hshefu'
client_key = '/Users/harishefu/.chef/hshefu.pem'
chef_server_url = 'https://chef-server.4thcafe.com/organizations/web-team'
```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}

## Setup TLS/SSL

All communication between Chef Workstation and the Chef Infra Server uses transport layer security and secure socket layer protocols (TLS/SSL) verification for security purposes.

Ideally, you will set up your Chef Infra Server using a certificate signed by a trusted certificate authority (CA), which will let you communicate with your server automatically.

Chef Infra Server generates a self-signed certificate during the setup process unless you supply a trusted CA certificate. Because this certificate is unique to your server, you will need to take additional steps to enable communication between the Chef Infra Client and Server.

To set up Chef Workstation to communicate with your Chef Infra Server, you need the to download files to your `.chef` directory.

The steps for downloading or generating these files vary depending on how you interact with Chef Infra Server. Select the option that best describes how you interact with the server:

- From the command line
- From macOS/Linux Hosted Chef or Chef Manage user interface (UI)
- From Windows Hosted Chef or Chef Manage UI

### From the Command Line
<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="tls-cli" tab-text="Command Line">}}
{{< foundation_tab panel-link="tls-nix-ui" tab-text="macOS/Linux Chef UI" >}}
{{< foundation_tab panel-link="tls-win-ui" tab-text="Windows Chef UI" >}}

{{< /foundation_tabs >}}
<!----End Tabs --->

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="tls-cli" >}}
If you interact with your Chef Infra Server from the command line, then you will need to:

- Retrieve your user private key, the `USER.pem` file, from your Chef Infra Server and save it in your .chef directory
- Configure the `knife` tool
- Use `knife` to download and save your server's digital certificates

Download the `USER.pem` files from the Chef Infra Server and move them to the `.chef` directory.

#### Get SSL Certificates

In the final step of setting up TLS/SSL with a custom CA certificate, you'll use the `knife ssl fetch` subcommand to download the the Chef Infra Server TLS/SSL certificate and save it in your `.chef/trusted_certs`.

Chef Infra verifies the security of all requests made to the server from tools such a knife and Chef Infra Client. The certificate that is generated during the installation of the Chef Infra Server is self-signed, which means there isn't a signing certificate authority (CA) to verify. In addition, this certificate must be downloaded to any machine from which knife and/or Chef Infra Client will make requests to the Chef Infra Server.

Use the `knife ssl fetch` subcommand to pull the SSL certificate down from the Chef Infra Server:

``` bash
knife ssl fetch
```

See [SSL Certificates](/chef_client_security/#ssl-certificates) for more information about how knife and Chef Infra Client use SSL certificates generated by the Chef Infra Server.

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="tls-nix-ui" >}}

### From Hosted Chef or Chef Manage

If you have interact with Chef Infra Server through the Hosted Chef or legacy Chef Manage web interface, these steps will help you use the Chef Management Console to download the `.pem` and `config.rb` files.

#### Download Keys (.pem) and Configuration Files

For a Chef Workstation installation that will interact with the Chef Infra Server (including the hosted Chef Infra Server) web interface, log on and download the following files:

- Download the `config.rb` from the **Organizations** page.
- Download the `USER.pem` from the **Change Password** section of the **Account Management** page.

#### Move Keys and Configuration Files into the Chef Directory

After downloading the `config.rb` and `USER.pem` files from the Chef Infra Server, move them to the Chef directory on your computer. The Chef directory is `~/.chef` on macOS and Linux systems.

Move files to the `~/.chef` directory on macOS and Linux systems:

1. In a command window, enter each of the following:

    ``` bash
    cp /path/to/config.rb ~/.chef
    ```

    and:

    ``` bash
    cp /path/to/USER.pem ~/.chef
    ```

    `/path/to/` is the location of your downloaded files.

1. Verify that the files are in the `.chef` folder.

   ``` bash
   ls -la ~/.chef
   ```

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="tls-win-ui" >}}

### From Hosted Chef or Chef Manage

If you have interact with Chef Infra Server through the Hosted Chef or legacy Chef Manage web interface, these steps will help you use the Chef Management Console to download the `.pem` and `config.rb` files.

#### Download Keys (.pem) and Configuration Files

For a Chef Workstation installation that will interact with the Chef Infra Server (including the hosted Chef Infra Server) web interface, log on and download the following files:

- Download the `config.rb` from the **Organizations** page.
- Download the `USER.pem` from the **Change Password** section of the **Account Management** page.

#### Move Keys and Configuration Files into the Chef Directory

After downloading the  `config.rb` and `USER.pem` files from the Chef Infra Server, move them to the `.chef` directory on your computer. The Chef directory is `C:\.chef` on Windows.

Move files to the `C:\.chef` directory:

1. In a command window, enter each of the following:

    ```powershell
    Move-Item -Path C:\path\to\config.rb -Destination C:\.chef
    ```

    and:

    ```powershell
    Move-Item -Path C:\path\to\USER.pem -Destination C:\.chef
    ```

  `\path\to\` is the location of your downloaded files .

1. Verify that the files are in the `C:\.chef` folder.

   ```powershell
   Get-ChildItem -Path C:\.chef
   ```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}
<!----End Panels --->

## Verify Client-to-Server Communication

To verify that Chef Workstation can connect to the Chef Infra Server:

Enter the following:

``` bash
knife client list
```

to return a list of clients (registered nodes and Chef Workstation installations) that have access to the Chef Infra Server. For example:

``` bash
chef_machine
registered_node
```
