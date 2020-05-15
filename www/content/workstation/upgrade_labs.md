# Upgrading a Node From Chef Infra 12 to 16

## Overview

This document generally documents the most straightforward pattern of an upgrade from Chef Infra Client 12 to CHef Infra Client 16, potentially along with Chef Server upgrades as well. It is not meant to exclude other approaches.

All commands are run locally on your development workstation unless noted otherwise.

## Assumptions

### Chef Servers
This document assumes that you have two chef servers available to you - an existing Chef Server on some older version, to which your nodes are attached, and a new, blank Chef Server which is the latest version.

### Chef Nodes
You have one or more nodes you wish to upgrade that are running Chef Infra 12-15 and are bootstrapped to the older server.

### Connectivity
This document assumes that you have a user key for both of the chef servers and they are reachable from your development workstation.

#### Credential file setup

This document assumes you have setup your credentials using [knife profiles](https://docs.chef.io/workstation/knife_setup/#knife-profiles). This allows you to keep your keys in a `credentials` file, and makes switching between credentials easier.

For example, in `.chef/credentials`:
``` toml
[old-server]
client_name = "myuser"
chef_server_url = "https://old-chef-server.dev/organizations/my-org"
client_key = """
-----BEGIN RSA PRIVATE KEY-----
MMM+some+key+goes+here+MMM
-----END RSA PRIVATE KEY-----
"""

[new-server]
client_name = "myuser"
chef_server_url = "https://new-chef-server.dev/organizations/my-org"
client_key = """
-----BEGIN RSA PRIVATE KEY-----
MMM+another+key+goes+here+MMM
-----END RSA PRIVATE KEY-----
"""
```


#### Verify chef server connectivity

You should be able to run a knife command against each server and receive a reasonable response.

```
$ knife user list --profile old-server
my-user
$ knife user list --profile new-server
my-user
```

### Clean Convergence
This document assumes that the nodes that we are upgrading today are currently cleanly converging under the older version of Chef Infra Client.
Verify that the nodes are healthy by running:

```
$ knife status --profile old-server
42 minutes ago, node-01, ubuntu 18.04.
```

This command will display the time of the last successful chef run of each node.

### You Have Some Kind of Cookbook Pipeline
This document assumes that you have some kind of continuous integration pipeline setup for your cookbooks - that is, you have a version control system (for example, git); when you make a proposed change, there is at least some degree of automated testing; and when cookbooks are released, only the continuous delivery system can update the version and upload the cookbook to the chef server(s). The particular choices of technology and the detail of processes may vary from site to site, but so long as the key stages of a cookbook pipeline are in place, this document should apply.

## Install Local Tools

### Chef Workstation
Ensure you have the latest version of Chef Workstation. To install Chef Workstation, visit https://downloads.chef.io/chef-workstation and download the package for your local operating system. Install the package.

Set Chef Workstation as your local development shell by running `chef shell-init` and following the instructions. This ensures all the tools referenced in this documentation are added to your PATH.

## Configuration

### Feature Flag Configuration
Enable Upgrade Labs by clicking on the Chef Workstation tray icon, then selecting Preferences. Click the Advanced Tab and check the "chef analyze" box.

## Identify a Node
### Using chef report nodes
Run on your development workstation:
```
$ chef report nodes -p old-server

Analyzing nodes...

-- REPORT SUMMARY --

            Node Name             Chef Version    Operating System     Number Cookbooks
--------------------------------+--------------+---------------------+-------------------
  node-01                         12.22.5        windows v10.0.14393                 18
  node-02                         12.22.5        windows v10.0.14393                 18
  node-03                         12.22.5        windows v10.0.14393                  5
  node-04                         12.18.31       windows v6.3.9600                    5
Nodes report saved to /Users/cwolfe/.chef-workstation/reports/nodes-20200324135111.txt
```
You might select a node that has a simple setup, such as a relatively few number of cookbooks.
Examine the saved report to determine the list of cookbooks for your node.

### Using chef report cookbooks
Run:
```
$ chef report cookbooks -V -p old-server

        Cookbook         Version   Violations   Auto-correctable   Nodes Affected
-----------------------+---------+------------+------------------+-----------------
  cron                   1.7.5              1                  1                1
  upgrade_lab_problems   0.1.0              2                  2                1

Cookbooks report saved to /Users/cwolfe/.chef-workstation/reports/cookbooks-20200504155204.txt
```

This report shows that there are two cookbooks on the server. It analyzes the cookbooks, looking for cookbook issues that with will be problematic in later versions of the Chef Infra client byt running the `cookstyle` program. Here, we see that the `cron` cookbook has a single violation, and it is able to be auto-corrected by `cookstyle`.

## Capture the Node

### Run chef capture NODE

This command will download the node from Chef Server.  It will also assist you in obtaining and organizing the cookbooks needed to converge the node. Finally, it will generate a Kitchenfile allowing you to use Test Kitchen to perform local development.

Run:

```
 $ chef capture MYNODE
 - Setting up local repository
 - Capturing node object 'MYNODE'
 - Capturing cookbooks...
 - Capturing environment...
 - Capturing roles...
 - Writing kitchen configuration...

Repository has been created in './node-MYNODE-repo'.
```

### Locate the cookbooks' origin

At this point, `chef capture` will interactively prompt you to fetch the cookbooks from their original locations - ideally, you would obtain the cookbooks from their canonical source (that is `git clone` or other version control checkout operation). This allows you to make local changes while contributing the changes upstream to the canonical source.

If you do not have access to the canonical source of one or more cookbooks, `chef capture` will simply download those cookbooks from the chef server itself. That will allow you to make changes and upload the changed cookbooks to the chef server, but you will not be able to contribute your changes upstream.

### Expected Layout for Cookbook Checkout

If you do have access to one or more of the cookbooks' sources, it is simplest if you have the cookbooks checked out in one parent directory, similar to this:

```
/Users/you/my-cookbooks/
  ├── cron
  │   ├── .git/   # Or other version control bookkeeping
  │   ├── recipes/
  │   ├──...
  │   └── metadata.rb
  └── chef-client
      ├── .cvs/   # Or other version control bookkeeping
      ├── recipes/
      ├──...
      └── metadata.rb
```

If you have cookbooks in multiple locations, that will work as well, but will involve more prompting.

`chef capture` will first prompt you for the main location, similar to this:

```
Please clone or check out the following cookbooks locally
from their original sources, and provide the base path
for the checkout:

  - cron (v1.6.1)
  - chef-client (v4.3.0)
  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

If all cookbooks are not available in the same base location,
you will have a chance to provide additional locations.

If sources are not available for these cookbooks, leave this blank.

Checkout Location [none]:
```

Using the example above, you would enter `/Users/you/my-cookbooks` at the prompt.
```
Checkout Location [none]: /src/my-cookbooks
  Replacing cookbook: cron
  Replacing cookbook: chef-client
```

`chef capture` will then scan that path, looking for the cookbooks that it needs. If all cookbooks are found, it will finish; but if any are missing, it will prompt individually.

### Locating Individual Cookbook Checkouts

Suppose that your node requires 5 cookbooks:

  - cron (v1.6.1)
  - chef-client (v4.3.0)
  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

But only `cron` and `chef-client` are present in the directory you provided in the initial prompt. `chef capture` will now prompt you for the remaining three:

```
Please provide the base checkout path for the following
cookbooks, or leave blank if no more cookbooks are checked out:

  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

Checkout Location [none]:
```

If you have another checkout location that contains multiple cookbooks, you may enter it, or you may enter a location that contains just one cookbook.

### Falling Back to a Downloading a Cookbook from Chef Server

If you do not have access to the original version-controlled source of a cookbook, press return at the prompt and `chef capture` will use a copy of the cookbook downloaded from the Chef Server.

This is not an ideal practice.  You will likely be making changes to the cookbooks in the steps ahead. It is important that you be able to track those changes and test your changes in a continuous integration pipeline, which is beyond the scope of this document. If you make changes in a copy of the cookbook without version control information, it will be difficult to reconcile those changes in the future. If you find yourself in this situation, it is likely worth the effort to try to track down the version-controlled source.

```
Changes made to the following cookbooks in ./node-MYNODE-repo/cookbooks
cannot be saved upstream, though they can still be uploaded
to a Chef Server:

  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

You're ready to begin!

Start with 'kitchen converge'.  As you identify issues, you
can modify cookbooks in their original checkout locations or
in the repository's cookbooks directory and they will be picked
up on subsequent runs of 'kitchen converge'.
```

## Converge Locally

{{< note >}}
Be cautious when running your cookbooks locally. It is possible to accidentally impact production infrastructure based on settings in your cookbooks and attributes. Read over your cookbooks and attributes, especially attributes being set in roles and environments.  If needed, override attributes to be appropriate for local testing in your `kitchen.yml`.
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

Run, in the `node-MY_NODE-repo` directory:
```
$ kitchen converge
```
Watch for Chef Infra errors. If any occur, fix them.  Also consider running cookstyle (see below). Repeat as needed.

### Run CookStyle
To check for version upgrade issues, run:
```
$ cookstyle cookbooks/some-cookbook
```
Repeat this process for each cookbook that the node consumes.

## Correct any Cookbook Style Issues
### Using auto-correct
To auto-correct cookbook issues, run:
```
$ cookstyle -a cookbooks/some-cookbook
```
Other issues may require manual intervention and editing.
Repeat this process for each cookbook that the node consumes.

### Using the VSCode Plugin
While any editor can be used, the Chef Infra extension for Visual Studio Code features several code generators and helpful features, such as running cookstyle when recipes are saved.

### Check for Data Bags
If data bags are used, you will need a `data_bags` directory in your repo.
You will need to download the data_bags. Note that this command does not support embedded keys in credentials files, so you must place the key in a key file.

```
$ cd node-node-01-repo
$ knife download data_bags --chef-repo-path . --profile old-server --key my-old-key.pem
```

### Check for Server Searches
Check your cookbook code for Chef Infra Server searches, which will not be possible in an Effortless context. Identify locations making search calls and replace with other mechanisms of service discovery.
```
$ grep 'search(' -rn cookbooks
```

### Commit Your Changes to the Cookbooks

As you make changes to the cookbooks, follow normal SDLC practices by committing your changes to your cookbooks and submitting your changes to your cookbook pipeline to be tested by your automated testing system. Once the changes have passed testing, they cookbooks should receive new version numbers and be published to the new chef server by the continuous deployment system.

### Or Directly Upload to the New Server

If your organization does not have a cookbook pipeline in place, or if you are setting up a proof of concept, you can directly upload the cookbooks to the new server. This is not recommended because it makes it difficult to manage changes to cookbook code. Note that this command does not support embedded keys in credentials files, so you must place the key in a key file.

```
$ cd node-node-01-repo
$ knife upload cookbooks --chef-repo-path . --profile new-server --key my-new-key.pem
```

If you used data bags, also upload them to the new server:
```
$ knife upload data_bags --chef-repo-path . --profile new-server --key my-new-key.pem
```

## Move the Node to the New Server

### Issue a new Bootstrap Command

Migrate your node to the new server by running a bootstrap command similar to the following:
```
 $ knife bootstrap \
      --profile new-server --chef-license accept \
      -r cookbook::recipe,another_cookbook::recipe \
      -N node-01 -y --sudo \
      user@somehost.example
```

Optionally, delete your node record from the old server using:
```
 $ knife node delete node-01 --profile old-server
```

## Repeat as Needed

Happy converging!
