+++
title = "Upgrade Lab: Chef Infra Client 12 to 16"
draft = false

aliases = ["/upgrade_labs.html", "/upgrade_labs.html", "/upgrade_labs/", "/upgrade_labs/"]

[menu]
  [menu.workstation]
    title = "Upgrade Lab: Chef Infra 12 to 16"
    identifier = "chef_workstation/upgrade_labs.md Upgrade Chef"
    parent = "chef_workstation"
    weight = 35
+++

Chef's Upgrade Lab provides an isolated cookbook development environment and in-line support to help you upgrade your system, so you can stop using legacy Chef Infra and start using modern Chef Infra.

The Upgrade Lab provides a report of your existing nodes and cookbooks, so you'll know the scope of the work and you can identify a good place to start. Upgrade Lab works by capturing any node from the production environment and recreating it locally by generating a repository for that node, which provides you with a sandbox to work through upgrading and testing your cookbooks at a safe distance from your production environment.

## About This Guide

This guide covers the straightforward pattern of upgrading from Chef Infra Client 12 to Chef Infra Client 16---including upgrading Chef Infra Server as you go. While we think this is the smoothest path forward, it is not meant to exclude other approaches.

Unless otherwise indicated, you'll run all commands in your local development environment.

{{< note >}}
This guide illustrates the simple case of upgrading a single node in isolation, including migrating it from one Chef Infra Server to a new Chef Infra Server. More complex situations, such as those involving pooled nodes using Chef Infra Server search for peer discovery, are not covered here. Please contact [Chef Software customer support](https://www.chef.io/support/).
{{< /note >}}

## Chef Upgrade Lab Requirements

### System Architecture Requirements

The Chef Upgrade Lab makes some basic assumptions about your existing system:

* Two Chef Infra Servers
  -  A Chef Infra Server running some older version
  -  A newly installed Chef Infra Server running the latest software, set up and configured for knife, but otherwise empty
* One or more nodes
  - Running Chef Infra Client 12-15
  - Minimum 512 MB RAM
  - [Recommended](https://docs.chef.io/chef_system_requirements/#chef-infra-client) 5GB space
  - Bootstrapped to the older Chef Infra Server
  - `sudo` permissions on the node
  - SSH connectivity between the nodes and the administrator/developer workstation
* An administrator/developer workstation
  - 64-bit architecture
  - Minimum 4 GB RAM
  - Recommended 10 GB of available disk space for installing Chef Workstation and running the Chef Upgrade Lab

### Software Requirements

* Meet the [platform and system requirements](https://docs.chef.io/workstation/install_workstation/) for Chef Workstation
* Install or upgrade to the Chef Workstation [latest version](https://downloads.chef.io/chef-workstation)

Chef does not prescribe any specific editor. However, the [Chef Infra extension](https://marketplace.visualstudio.com/items?itemName=chef-software.Chef) for [Visual Studio Code](https://code.visualstudio.com/) features several code generators and helpful features, such as running Cookstyle each time you save a recipe.

### Server Backup

We recommend performing a backup before starting any server upgrade process.
Follow the [Chef Infra Server Backup](https://docs.chef.io/runbook/server_backup_restore/) documentation before starting your Upgrade Lab.

### Infrastructure Requirements

#### Credentials

Your credentials are set up using [knife profiles](https://docs.chef.io/workstation/knife_setup/#knife-profiles). This allows you to keep your keys in a `credentials` file, and makes switching between credentials easier.

For example, in `.chef/credentials`:

```toml
[old-server]
client_name = "user_name"
chef_server_url = "https://old-chef-server.dev/organizations/my-org"
client_key = """
-----BEGIN RSA PRIVATE KEY-----
MMM+some+key+goes+here+MMM
-----END RSA PRIVATE KEY-----
"""
[new-server]
client_name = "user_name"
chef_server_url = "https://new-chef-server.dev/organizations/my-org"
client_key = """
-----BEGIN RSA PRIVATE KEY-----
MMM+another+key+goes+here+MMM
-----END RSA PRIVATE KEY-----
"""
```

#### Connectivity

* You have a user key for both of the Chef Infra Servers
* You can connect to both Chef Infra Servers from your development workstation.

Verify connectivity by running a knife command against each server and receive a reasonable response:

```shell
chef exec knife user list --profile old-server
user_name
chef exec knife user list --profile new-server
user_name
```

#### Convergence

Your nodes are in a good working order. They converge cleanly under the older version of Chef Infra Client.

Verify that the nodes are healthy by running:

```shell
chef exec knife status --profile old-server
```

Which outputs something similar to:

```output
42 minutes ago, node-01, ubuntu 18.04.
```

This command outputs the time of the last successful chef run of each node; nodes that return radically different times for the last successful chef run are not in good working order.

#### Cookbook CI/CD

While we don't prescribe a particular choice of technology or the details of processes, the Chef Upgrade Lab expects a continuous integration pipeline and continuous delivery system (CI/CD) for cookbook deployments.

The Upgrade Lab assumes--but does not require--that you have a continuous integration pipeline (CI) setup for your cookbooks with:

  * A version control system (for example, git)
  * Some degree of automated testing for proposed changes
  * A continuous delivery system (CD) that controls cookbook releases; the CD is the mechanism for updating cookbook versions and uploading them to the Chef Infra Server(s)

If you do not have a version control system and CI/CD pipeline in place, then please contact [Chef Software customer support](https://www.chef.io/support/).

#### Cookbook Locations

Upgrading a node means upgrading its cookbooks so that it can run the latest version of CHef Infra Client.
Speed up the upgrade process by locating cookbooks on your system before you begin.
Ideally, you can get the cookbooks from their canonical source (that is, `git clone` or another similar version control operation). If you're working with a version control system, you can make and test your changes locally and then push the changes back to the cookbook's source. This fully leverages the benefits of your cookbook CI/CD pipeline by allowing your changes to go through proper version control, peer review, automated testing, and automated deployment.
If you can't locate a cookbook, do not download it from an external source, such as the public Chef Supermarket. The cookbook version in your development environment must match the version on your node. [As a last resort](/upgrade_labs/#cookbooks-on-the-chef-server), the Upgrade Lab can get copies of your cookbooks from the Chef Infra Server during the `capture` phase.

Likely cookbook locations:

* Checked into your version control system
* On a private Supermarket installation
* In an existing [cookbook development directory](/upgrade_labs/#expected-cookbook-directory-layout)

##### Cookbook Directory Layout

If you have access to cookbook sources, it is simplest if you have the cookbooks stored in one parent directory, similar to this:

```
/Users/user_name/my_cookbooks/
  ├── cron
  │   ├── .git/   # Or other version control bookkeeping
  │   ├── recipes/
  │   ├──...
  │   └── metadata.rb
  └── chef-client
  │   ├── .cvs/   # Or other version control bookkeeping
  │   ├── recipes/
  │   ├──...
  │   └── metadata.rb
  └── my_custom_cookbook
      ├── .git/   # Or other version control bookkeeping
      ├── recipes/
      ├──...
      └── metadata.rb
```

The Upgrade Lab works if you have cookbooks in different locations, but it involves more prompting from the command line.

## Upgrade Lab

### Inventory your system with Chef Reports

We recommend starting the upgrade process on a node with a simple setup, such as one with fewer and simpler cookbooks.
The `chef report` command surveys your nodes and cookbooks. Use the reports to identify a good starting place.

#### chef report nodes

Use `chef report nodes -p PROFILE` command to create a report of the nodes in your system from Ohai data. The command:

* Prints a report summary to the screen
* Saves the report to the `.chef-workstation/reports/` directory.

Create a node report from your development workstation by running:

```shell
chef report nodes -p old-server
```

Which outputs a node report:

```output
Analyzing nodes...

-- REPORT SUMMARY --

            Node Name             Chef Version    Operating System     Number Cookbooks
--------------------------------+--------------+---------------------+-------------------
  node-01                         12.22.5        windows v10.0.14393                 18
  node-02                         12.22.5        windows v10.0.14393                 18
  node-03                         12.22.5        windows v10.0.14393                  5
  node-04                         12.18.31       windows v6.3.9600                    5
Nodes report saved to /Users/user_name/.chef-workstation/reports/nodes-20200324135111.txt
```

#### chef report cookbooks

Use `chef report cookbooks -p PROFILE` command to create a report of the cookbooks in your system from Ohai data. The command:

* Prints a report summary to the screen
* Saves the report to the `.chef-workstation/reports/` directory.

This report shows that there are two cookbooks on the server. It analyzes the cookbooks, looking for cookbook issues that will be problematic in later versions of the Chef Infra Client by running the `cookstyle` program. Here, we see that the `cron` cookbook has a single violation, and which can be auto-corrected by `cookstyle`.

Create a cookbook report from your development workstation by running:

```
chef analyze report cookbooks -V -p old-server
```

Which outputs a cookbook report:

```
        Cookbook         Version   Violations   Auto-correctable   Nodes Affected
-----------------------+---------+------------+------------------+-----------------
  cron                   1.7.5              1                  1                1
  upgrade_labs_problems   0.1.0              2                  2                1

Cookbooks report saved to /Users/user_name/.chef-workstation/reports/cookbooks-20200504155204.txt
```

### Create an Upgrade Environment with chef capture

`chef capture NODE`

* Creates a repository for that node in the current directory
* Helps you obtain and organize the cookbooks you need to converge the node
* Creates a `kitchen.yml`, which allows you to use Test Kitchen to perform local development

Run:

```
 chef capture NODE
```

The screen output describes the capture process:

```
 - Setting up local repository
 - Capturing node object ''
 - Capturing cookbooks...
 - Capturing environment...
 - Capturing roles...
 - Writing kitchen configuration...

Repository has been created in './node-NODE-repo'.
```

#### Add Cookbook Source Locations

After creating the repo, `chef capture NODE` prompts you to fetch the cookbooks from their original locations.

##### Main Cookbook Development Location

The `chef capture` command prompts you first for your main cookbook source location.

```
Next, locate version-controlled copies of the cookbooks. This is
important so that you can track changes to the cookbooks as you
edit them. You may have one or more existing paths where you have
checked out cookbooks. If not, now is a good time to open a
separate terminal and clone or check out the cookbooks.

If all cookbooks are not available in the same base location,
you will have a chance to provide additional locations.

Press Enter to Continue:

Please clone or check out the following cookbooks locally
from their original sources, and provide the base path
for the checkout:

  - cron (v1.6.1)
  - chef-client (v4.3.0)
  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

If sources are not available for these cookbooks, leave this blank.

Checkout Location [none]:
```

At this point, enter the path to your [cookbook development directory](/#cookbook-directory-layout), for example, `/Users/user_name/my_cookbooks` at the prompt.


`chef capture` scans that path and locates the cookbooks that it needs. The command finishes once it accounts for all cookbook sources; but if any are missing, it will prompt for them in the next step.

```
Checkout Location [none]: /src/my_cookbooks
  Using your checked-out cookbook: cron
  using your checked-out cookbook: chef-client
```

##### Alternate Cookbook Source Locations

Suppose that your node requires 5 cookbooks:

  - cron (v1.6.1)
  - chef-client (v4.3.0)
  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

If the directory you provided in the initial prompt contains only `cron` and `chef-client`, then `chef capture` prompts you to add the locations for sources for the remaining three:

```
Please provide the base checkout path for the following
cookbooks, or leave blank if no more cookbooks are checked out:

  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

Checkout Location [none]:
```

`chef capture` scans the path that you provide and locates the cookbooks that it needs. The command finishes once it accounts for all cookbook sources; it prompts you for another path if it needs more cookbook sources.

### Download Cookbooks from Chef Infra Server

If you do not have access to the original version-controlled source of a cookbook, press return at the prompt for `chef capture`  to use a copy of the cookbook downloaded from the Chef Infra Server.

Upgrading cookbooks from the Chef Infra Server is not an ideal practice. You will make changes to your cookbooks in the course of the upgrade.  Making changes to your cookbooks without the ability to track your changes in version control almost inevitably leads to conflicts between cookbook sources. Reconciling cookbooks with untracked changes is a difficult and time-consuming process. If you find yourself using many cookbooks--or complex cookbooks--downloaded from the Chef Infra Server, it will be worth the effort in the long run to try to track down their version-controlled sources.

Tracking and testing changes in a CI/CD pipeline is an important part of managing your Chef infrastructure but are beyond the scope of this guide. See [Learn Chef Rally](https://learn.chef.io/) for tutorials and contact [Chef Software customer support](https://www.chef.io/support/) when you are ready to modernize your system.

```
------------------------ WARNING ---------------------------
Changes made to the following cookbooks in ./node-MYNODE-repo/cookbooks
cannot be saved to the cookbook's source, though they can still be uploaded
to a Chef Server:

  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)
-----------------------------------------------------------

You're ready to begin!

Start with 'kitchen converge'.  As you identify issues, you
can modify cookbooks in their original checkout locations or
in the repository's cookbooks directory and they will be picked
up on subsequent runs of 'kitchen converge'.
```

## Detect and Correct Cookbook Errors

{{< note >}}
Be cautious when running your cookbooks locally. It is possible to accidentally impact production infrastructure based on settings in your cookbooks and attributes. Read over your cookbooks and attributes, especially attributes set in roles and environments.  If needed, override attributes to be appropriate for local testing in your `kitchen.yml`.
{{< /note >}}

### Increment the Chef Infra Client Version

In the `kitchen.yml` file, change the `product_version` line to `16`:

```yaml
provisioner:
  name: chef_zero
  product_name: chef
  product_version: 16  # Change this line
```

If needed, you can "step forward" by first going from 12 to 13, correcting issues, then 13 to 14, etc.

### Attempt a Converge and Check for Errors

Save the file and test it in the `node-MY_NODE-repo` directory by running:

```
chef exec kitchen converge
```

Watch for Chef Infra errors. If any occur, fix them.

### Test and Correct with Cookstyle

To check for version upgrade issues, run:

```
$ chef exec cookstyle cookbooks/my_cookbook
```

Repeat this process for each cookbook for that node.

#### Using Cookstyle Auto-correct

Use Cookstyle's auto-correct feature to fix style errors by adding the `-a` (for auto-correct) flag:

```
$ chef exec cookstyle -a cookbooks/my_cookbook
```

Other issues may require manual intervention and editing.
Repeat this process for each cookbook that the node consumes.

### Copy Data Bags

If data bags are used on your Chef Infra Server, you will need to download the `data_bags` directory in your repository.
Note that this command does not support embedded keys in credentials files. If you use embedded keys, move the key to a key file.

```
cd node-node-01-repo
chef exec knife download data_bags --chef-repo-path . --profile old-server --key my-old-key.pem
```

## Deploy your Chef Lab Upgrades

{{< note >}}
This guide suggests migrating upgraded cookbooks and nodes to a new Chef Server. This pattern is not feasable for all customers, specifically ones who rely on Chef search for inventory and coordination. But we feel migrating to a new server works for customers who do not rely on search because it creates a fresh start to build on for future migration to Effortless.

If you rely on knife search, or setting up a new Chef Server is unfeasable, upload the upgraded cookbooks to your existing Chef Server. If you do this be sure to pin your cookbook versions on existing nodes, so that the upgraded cookbook can be manually promoted to desired nodes.
{{< /note >}}

### Commit Your Cookbook Upgrades

As you make changes to the cookbooks, follow your organization's existing software development practices by committing your changes to your cookbooks and submitting your changes to your cookbook pipeline to be tested by your automated testing system. Once the changes have passed testing, the cookbooks should receive new version numbers and be published to the new Chef Infra Server by the continuous deployment system.

### Upload your Cookbook Upgrades to the New Server

If your organization does not have a cookbook pipeline in place, or if you are setting up a proof of concept, you can directly upload the cookbooks to the new server. This is not recommended because it makes it difficult to manage changes to cookbook code. Note that this command does not support embedded keys in credentials files, so you must place the key in a key file.

```
$ cd node-node-01-repo
$ chef exec knife upload cookbooks --chef-repo-path . --profile new-server --key ../keys/my-new-key.pem
```

If you used data bags, also upload them to the new server:

```
$ chef exec knife upload data_bags --chef-repo-path . --profile new-server --key ../keys/my-new-key.pem
```

## Attach the Upgraded Node to the New Server

### Issue a new Bootstrap Command

Migrate your node to the new server by running a bootstrap command similar to the following:

```
 $ chef exec knife bootstrap \
      --profile new-server --chef-license accept \
      -r cookbook::recipe,another_cookbook::recipe \
      -N node-01 -y --sudo \
      user@somehost.example
```

Optionally, delete your node record from the old server using:

```
 $ chef exec knife node delete node-01 --profile old-server
```

## Repeat as Needed

Happy Converging!
