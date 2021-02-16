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

This guide contains common configuration options used when setting up a
new Chef Workstation installation. If you do not have Chef Workstation
installed, see its [installation guide](/workstation/install_workstation/)
before proceeding further.

## Configure Ruby Environment

For many users of Chef, the version of Ruby that is included in Chef
Workstation should be configured as the default version of Ruby on your
system.

{{< note >}}

These instructions are intended for macOS and Linux users. On Windows Chef Workstation includes a desktop shortcut to a PowerShell prompt already configured for use.

{{< /note >}}

1. Open a terminal and enter the following:

    ``` bash
    which ruby
    ```

    which will return something like `/usr/bin/ruby`.

2. To use Chef Workstation-provided Ruby as the default Ruby on your system, edit the `$PATH` and `GEM` environment variables to include paths to Chef Workstation. For example, on a machine that runs Bash, run:

    ``` bash
    echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
    ```

    where `bash` and `~/.bash_profile` represents the name of the shell.

    If zsh is your preferred shell then run the following:

    ``` bash
    echo 'eval "$(chef shell-init zsh)"' >> ~/.zshrc
    ```

3. Run `which ruby` again. It should return
    `/opt/chef-workstation/embedded/bin/ruby`.

{{< note >}}

Using Chef Workstation-provided Ruby as your system Ruby is optional.
For many users, Ruby is primarily used for authoring Chef cookbooks. If
that's true for you, then using the Chef Workstation-provided Ruby is
recommended.

{{< /note >}}

## Add Ruby to $PATH

Chef Infra Client includes a stable version of Ruby as part of its
installer. The path to this version of Ruby must be added to the `$PATH`
environment variable and saved in the configuration file for the command
shell (Bash, csh, and so on) that is used on the machine running Chef
Workstation. In a command window, type the following:

``` bash
echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.configuration_file && source ~/.configuration_file
```

where `configuration_file` is the name of the configuration file for the
specific command shell. For example, if Bash were the command shell and
the configuration file were named `bash_profile`, the command would look
something like the following:

``` bash
echo 'export PATH="/opt/chef-workstation/embedded/bin:$PATH"' >> ~/.bash_profile && source ~/.bash_profile
```

{{< warning >}}

On Microsoft Windows, `C:/opscode/Chef Workstation/bin` must be before
`C:/opscode/Chef Workstation/embedded/bin` in the `PATH`.

{{< /warning >}}

## Setup Your Chef Repo

{{% chef_repo_description %}}

If you're setting up Chef for the very first time **in your organization**, then you will need a Chef Infra repository for saving your cookbooks and other work.

Use the [chef generate repo]({{< relref "ctl_chef.md#chef-generate-repo" >}}) command to create your Chef Infra repository. For example, to create a repository called
`chef-repo`:

``` bash
chef generate repo chef-repo
```

### Install a Code Editor

A good visual code editor is not a requirement for working with Chef
Infra, but a good code editor can save you time. A code editor should
support the following: themes, plugins, snippets, syntax Ruby code
coloring/highlighting, multiple cursors, a tree view of the entire
folder/repository you are working with, and a Git integration.

These are a few common editors:

- [Visual Studio Code (free/open source)](http://code.visualstudio.com)
- [GitHub Atom - (free/open source)](http://atom.io)

Chef Infra support in editors:

- [VSCode Chef Infra Extension](https://marketplace.visualstudio.com/items?itemName=chef-software.Chef)
- [Chef on Atom](https://atom.io/packages/language-chef)

## Your Chef Workstation Installation

Chef Workstation installs [Chef products and tools]({{< relref "install_workstation.md" >}}) onto your computer.

Chef Workstation includes:

- **Chef Tools**: Chef Infra Client, Chef InSpec and Chef Habitat
- **Chef Language**: Pre-built resources for managing systems as well as helpers to make authoring and distributing cookbooks an ease
- **Testing and Upgrade Tools**: Test Kitchen, Chef Cookstyle and Chef Upgrade Lab

The first time you run the Chef Workstation app, it creates a `.chef` directory in your user directory. The `.chef` directory is where you will store your Chef Workstation configuration and your client keys.

### HOW TO DO THIS AS ADMIN

Create user: https://docs.chef.io/server/ctl_chef_server/#user-management
<!-- The server generates a RSA private key
your administrator provides you with a RSA private key
Once you have a copy of your certificate to authorize you -->

### Move your Client Certificate

Your client certificate is an RSA private key in the `.pem` format that your Chef Infra Server administrator provides to you.

Each Chef Workstation user has a unique client certificate, which corresponds to a client on the Chef Infra Server that your server administrator creates for you.

Save your client certificate in the `.chef` directory using the same name as the client created by your server administrator.

### Create Your User Credentials File

Your `.chef` directory contains an example client `credentials` file, which you can modify to setup communication with your Chef Infra Server.

At a minimum, you must update the following settings with the appropriate values:

- `client_name`: the client name your server administrator created for you
- `client_key`: the path to the client key in your `.chef` directory
- `chef_server_url`: the full URL to your Chef Infra Server including the org

See the [knife config.rb documentation](/workstation/config_rb/) for more
details.

<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="knife-config-example" tab-text="Example credentials">}}
{{< foundation_tab panel-link="knife-config-demo" tab-text="Completed credentials" >}}
{{< /foundation_tabs >}}
<!----End Tabs --->

```bash
# This is the Chef Infra credentials file used by the knife CLI and other tools
# This file supports defining multiple credentials profiles, to allow you to switch between users, orgs, and Chef Infra Servers.

# Example credential file configuration:
# [default]
# client_name = 'MY_USERNAME'
# client_key = '/Users/USERNAME/.chef/MY_USERNAME.pem'
# chef_server_url = 'https://api.chef.io/organizations/MY_ORG'
```

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="knife-cred-example" >}}


{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="knife-cred-demo" >}}

```bash
# This is the Chef Infra credentials file used by the knife CLI and other tools
# This file supports defining multiple credentials profiles, to allow you to switch between users, orgs, and Chef Infra Servers.

# Example credential file configuration:
# [default]
# client_name = 'hshefu'
# client_key = '/Users/harishefu/.chef/hshefu.pem'
# chef_server_url = 'https://chef-server.4thcafe.com/organizations/web-team'
```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}

## Setup TLS/SSL

All communication between Chef Workstation and the Chef Infra Server uses transport layer security and secure socket layer protocols (TLS/SSL) verification for security purposes.

Ideally, you will set up your Chef Infra Server using a certificate signed by a trusted certificate authority (CA), which will let you communicate with your server automatically.

Chef Infra Server automatically generates a self-signed certificate during the setup process unless you provide it a trusted CA certificate. Because this certificate is unique to your server, you will need to take additional steps to enable communication between the Chef Infra Client and Server.

Setting up Chef Workstation to trust the server's self-signed certificates you can use the `knife ssl fetch` subcommand to download the TLS/SSL certificate from the Chef Infra Server:

To set up Chef Workstation to communicate with your Chef Infra Server, you need the to download the following file in your `.chef` directory:

* USER.pem

The steps for downloading or generating these files vary depending on how you interact with Chef Infra Server. Select the option that best describes how you interact with the server:

* [From the command line]({{< relref "#From the Command Line">}})
* [From Hosted Chef or Chef Manage]({{< relref "#From Hosted Chef or Chef Manage" >}})

### From the Command Line

If you interact with your Chef Infra Server from the command line, then you will need to:

* Retrieve your user private key, the `USER.pem` file, from your Chef Infra server and save it in your Chef directory
* Configure the `knife` tool
* Use `knife` to download and save your server's digital certificates

Download the `USER.pem` files from the Chef Infra Server and move them to the `.chef` directory.

#### Get SSL Certificates

Chef Server 12 and later enables SSL verification by default for all
requests made to the server, such as those made by knife and Chef Infra
Client. The certificate that is generated during the installation of the
Chef Infra Server is self-signed, which means there isn't a signing
certificate authority (CA) to verify. In addition, this certificate must
be downloaded to any machine from which knife and/or Chef Infra Client
will make requests to the Chef Infra Server.

Use the `knife ssl fetch` subcommand to pull the SSL certificate down
from the Chef Infra Server:

``` bash
knife ssl fetch
```

See [SSL Certificates](/chef_client_security/#ssl-certificates) for
more information about how knife and Chef Infra Client use SSL
certificates generated by the Chef Infra Server.

### From Hosted Chef or Chef Manage

If you have interact with Chef Infra Server through the Hosted Chef or legacy Chef Manage web interface, these steps will help you use the Chef Management Console to download the `.pem` and `config.rb` files.

#### Download Keys (.pem) and Configuration Files

For a Chef Workstation installation that will interact with the Chef
Infra Server (including the hosted Chef Infra Server), log on and
download the following files:

* Download the `config.rb` from the **Organizations** page.
* Download the `USER.pem` from the **Change Password** section of the **Account Management** page.

#### Move Keys and Configuration Files into the Chef Directory

After downloading the  `config.rb` and `USER.pem` files from the Chef Infra Server, move them to the Chef directory on your computer. The Chef directory is `~/.chef` on macOS and Linux systems and `C:\\chef` on Windows.
<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="webui-macOS-panel" tab-text="macOS/Linux">}}
{{< foundation_tab panel-link="webui-win-panel" tab-text="Windows" >}}

{{< /foundation_tabs >}}
<!----End Tabs --->

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="webui-macOS-panel" >}}

Move files to the `.chef` directory on macOS and Linux systems:

1. In a command window, enter each of the following:

    ``` bash
    cp /path/to/config.rb ~/.chef
    ```

    and:

    ``` bash
    cp /path/to/USER.pem ~/.chef
    ```

    where `/path/to/` represents the path to the location in which these
    three files were placed after they were downloaded.

1. Verify that the files are in the `.chef` folder.

   ``` bash
   ls -la ~/.chef
   ```

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="webui-win-panel" >}}

Move files to the `C:\chef` directory on macOS and Linux systems:

1. In a command window, enter each of the following:

    ```powershell
    Move-Item -Path C:\path\to\config.rb -Destination C:\chef\
    ```

    and:

    ```powershell
    Move-Item -Path C:\path\to\USER.pem -Destination C:\chef\
    ```

    where `/path/to/` represents the path to the location in which these
    three files were placed after they were downloaded.

1. Verify that the files are in the `C:\chef` folder.

   ```powershell
   Get-ChildItem -Path C:\chef
   ```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}

## Verify Client-to-Server TLS/SSL Communication

To verify that Chef Workstation can connect to the Chef Infra Server:

Enter the following:

  ``` bash
  knife client list
  ```

  to return a list of clients (registered nodes and Chef Workstation
  installations) that have access to the Chef Infra Server. For
  example:

  ``` bash
  chef_machine
  registered_node
  ```
