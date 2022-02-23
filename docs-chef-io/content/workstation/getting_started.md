+++
title = "Setup Chef Workstation"
draft = false

gh_repo = "chef-workstation"

aliases = ["/workstation_setup.html", "/chefdk_setup.html", "/workstation.html", "/workstation_setup/"]

[menu]
  [menu.workstation]
    title = "Setup"
    identifier = "chef_workstation/setup.md Setup Chef Workstation"
    parent = "chef_workstation"
    weight = 30
+++

This guide walks you through the four parts to set up Chef Workstation on your computer.

- [Configure Ruby Environment]({{< relref "#configure-ruby-environment" >}})
- [Set up your chef-repo]({{< relref "#setup-your-chef-repo" >}}) for storing your cookbooks
- [Setup Chef Credentials]({{< relref "#setup-chef-credentials" >}})
- [Verify Client-to-Server Communication]({{< relref "#Verify Client-to-Server Communication" >}})

## Prerequisites

1. [Download and install Chef Workstation]({{< relref "install_workstation.md" >}})
1. A running instance of [Chef Infra Server]({{< relref "server/install_server.md" >}}) or [Hosted Chef Server](https://manage.chef.io/signup).
1. Unless using Chef Manage or Hosted Chef, the `CLIENT.PEM` file supplied by your Chef administrator.

## Configure Ruby Environment

For many users, Ruby is primarily used for developing Chef policy (for example, cookbooks, Policyfiles, and Chef InSpec profiles). If that's true for you, then we recommend using the Chef Workstation Ruby as your default system Ruby. If you use Ruby for software development, you'll want to skip this step.

{{< note >}}

These instructions are intended for macOS and Linux users. On Windows, Chef Workstation includes a desktop shortcut to a PowerShell prompt already configured for use.

{{< /note >}}

 1. Determine your default shell by running:

    ```bash
    echo $SHELL
    ```

    This will give you the path to your default shell such as `/bin/zsh` for the Zsh shell.

 1. Add the Workstation initialization content to the appropriate shell rc file:

    For Bash shells run:

    ``` bash
    echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
    ```

    For Zsh shells run:

    ``` bash
    echo 'eval "$(chef shell-init zsh)"' >> ~/.zshrc
    ```

    For Fish shells run:

    ``` bash
    echo 'eval (chef shell-init fish)' >> ~/.config/fish/config.fish
    ```

 1. Open a new shell window and run:

    ```bash
    which ruby
    ```

    The command should return `/opt/chef-workstation/embedded/bin/ruby`.

## Setup Your Chef Repo

If you're setting up Chef for the very first time **in your organization**, then you will need a Chef Infra repository for saving your cookbooks and other work.

{{% chef_repo_description %}}

Use the [chef generate repo]({{< relref "ctl_chef.md#chef-generate-repo" >}}) command to create your Chef Infra repository. For example, to create a repository called `chef-repo`:

``` bash
chef generate repo chef-repo
```

## Setup Chef Credentials

The first time you run the Chef Workstation app, it creates a `.chef` directory in your user directory. The `.chef` directory is where you will store your Chef Workstation configuration and your client keys.

If you're setting up Chef Workstation **as a Chef Infra Server administrator**, then you will need to manage users with the [Chef Infra Server CLI](https://docs.chef.io/server/ctl_chef_server/#user-management) or the Manage UI. When you create a new user, a user-specific RSA client key will be generated, which you then need to share securely with that user.

If you're setting up Chef Workstation **as a Chef user**, then you will need to setup your unique client private key that corresponds to a client on the Chef Infra Server that your server administrator creates for you. The client private key is an RSA private key in the `.pem` format.

### Configure Your User Credentials File

Your `.chef` directory contains a `credentials` file used to communicate with the Chef Infra Server. You can generate this file by running `knife configure` and following the prompts.

The `knife configure` command requires the following values:

- `Chef Server URL`: the full URL to your Chef Infra Server including the org
- `Client Name`: the client name your server administrator created for you

Your Chef administrator should provide this information. For Hosted Chef or Chef Manage, you can find this information in the Starter Kit file. Download the file on the Manage site by navigating to the Administration tab and selecting Starter Kit. (**Manage > Administration > Starter Kit > Download Starter Kit**)

Find the `.chef/config.rb` file in the Starter Kit. It should look like:

```ruby
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "hshefu"
client_key               "#{current_dir}/hshefu.pem"
chef_server_url          "https://api.chef.io/organizations/4thcafe-web-team"
cookbook_path            ["#{current_dir}/../cookbooks"]
```

Use the `chef_server_url` and `node_name` values from this file when running `knife configure`.

### Setup Your Client Private Key

All communication between Chef Workstation and the Chef Infra Server is authenticated using an RSA public/private key pair. This pair is generated on the Chef Infra Server and the private key must be copied to your local Chef Workstation installation for communication to function.

The steps for downloading or generating these files vary depending on how you interact with Chef Infra Server. Select the option that best describes how you interact with the server:

<!----Tabs Section--->
{{< foundation_tabs tabs-id="tabs-panel-container" >}}
{{< foundation_tab active="true" panel-link="infra_and_automate_keys" tab-text="Chef Infra Server / Automate">}}
{{< foundation_tab panel-link="hosted-keys" tab-text="Hosted Chef / Manage" >}}
{{< /foundation_tabs >}}
<!----End Tabs --->

<!----Panels Section --->
{{< foundation_tabs_panels tabs-id="tabs-panel-container" >}}
{{< foundation_tabs_panel active="true" panel-id="infra_and_automate_keys" >}}

Your Chef administrator will provide you with your client.pem file. Copy this file to the `~/.chef` directory.

On macOS and Linux systems this looks something like:

```bash
cp ~/Downloads/MY_NAME.pem ~/.chef/
```

On Windows systems this will look something like this:

```powershell
Copy-Item -Path C:\Users\MY_NAME\Downloads\MY_NAME.pem -Destination C:\Users\MY_NAME\.chef\
```

{{< /foundation_tabs_panel >}}
{{< foundation_tabs_panel panel-id="hosted-keys" >}}

The client key file is located in the Starter Kit at `.chef/MY_NAME.pem`. Copy the .pem file to the `~/.chef` directory.

On macOS and Linux systems this looks something like:

```bash
cp ~/Downloads/chef-repo/.chef/MY_NAME.pem ~/.chef/
```

On Windows systems this will look something like this:

```powershell
Copy-Item -Path C:\Users\MY_NAME\Downloads\chef-repo\.chef\MY_NAME.pem -Destination C:\Users\MY_NAME\.chef\
```

{{< /foundation_tabs_panel >}}
{{< /foundation_tabs_panels >}}
<!----End Panels --->

## Verify Client-to-Server Communication

To verify that Chef Workstation can connect to the Chef Infra Server:

Run the following command on the command line:

``` bash
knife client list
```

Which should return a list of clients similar to:

``` bash
chef_machine
registered_node
```

### Fetch Self Signed Certificates

If the Chef Infra Server you're configured to use has a self signed certificate, you'll use the `knife ssl fetch` subcommand to download the the Chef Infra Server TLS/SSL certificate and save it in your `.chef/trusted_certs`.

Chef Infra verifies the security of all requests made to the server from tools such a knife and Chef Infra Client. The certificate that is generated during the installation of the Chef Infra Server is self-signed, which means there isn't a signing certificate authority (CA) to verify. In addition, this certificate must be downloaded to any machine from which knife and/or Chef Infra Client will make requests to the Chef Infra Server.

Use the `knife ssl fetch` subcommand to pull the SSL certificate down from the Chef Infra Server:

``` bash
knife ssl fetch
```

See [SSL Certificates](/chef_client_security/#ssl-certificates) for more information about how knife and Chef Infra Client use SSL certificates generated by the Chef Infra Server.
