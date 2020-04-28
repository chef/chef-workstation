# Upgrading a Node to Effortless

## Overview

This document generally documents the most straightforward pattern of an upgrade from an attribute-based cookbook usage pattern to Policyfiles, then to Effortless. It is not meant to exclude other approaches.  Primarily, it is meant to discover where pain points exist, and where new tooling may be added to ease that pain.

This is a descriptive document of the current process, not an aspirational document.

End goal: have an Habitat package that contains Chef Infra, the node's policyfile, cookbooks, data bags, and attributes; install that package on the node with the chef effortless scaffolding.

All commands are run locally on your development workstation unless noted otherwise.

## Install Local Tools

### Chef Workstation
To install Chef Workstation, visit https://downloads.chef.io/chef-workstation and download the package for your local operating system. Install the package.

### Chef Habitat
To install the Chef Habitat CLI tool, visit https://www.habitat.sh/docs/install-habitat/ and follow the instructions for your operating system.

## Configuration
### Chef Client Configuration
Configure your Chef client to communicate with the Chef Infra Server by setting up the `~/.chef/client.rb` and optionally the `~/.chef/credentials` files.  For details, see [config_rb_client](https://docs.chef.io/config_rb_client/). Keep in mind that once the node is converted to Effortless, this configuration will not be used again (except perhaps to convert other nodes on the same server).

For our purposes today, set:
```
cookbook_path ["./cookbooks"]
```

### Feature Flag Configuration
Enable Chef Analyze by clicking on the Chef Workstation tray icon, then selecting Preferences. Click the Advanced Tab and check the "chef analyze" box.

### Habitat Setup
First, setup your builder token and origin using [these instructions](https://www.habitat.sh/docs/using-builder/#builder-token). Then, setup your hab CLI:

```
$ hab cli setup
```

## Identify a Node
### Using chef analyze report nodes
Run on your development workstation:
```
$ chef analyze report nodes

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


## Capture the Node

### Run chef analyze capture NODE

This command will download the node from Chef Server.  It will also assist you in obtaining and organizing the cookbooks needed to converge the node. Finally, it will generate a Kitchenfile allowing you to use Test Kitchen to perform local development.

Run:

```
 $ chef analyze capture MYNODE
 - Setting up local repository
 - Capturing node object 'MYNODE'
 - Capturing cookbooks...
 - Capturing environment...
 - Capturing roles...
 - Writing kitchen configuration...

Repository has been created in './node-MYNODE-repo'.
```

### Locate the cookbooks' origin

At this point, `chef analyze capture` will interactively prompt you to fetch the cookbooks from their original locations - ideally, you would obtain the cookbooks from their canonical source (that is `git clone` or other version control checkout operation). This allows you to make local changes while contributing the changes upstream to the canonical source.

If you do not have access to the canonical source of one or more cookbooks, `chef analyze capture` will simply download those cookbooks from the chef server itself. That will allow you to make changes and upload the changed cookbooks to the chef server, but you will not be able to contribute your changes upstream.

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

`chef analyze capture` will first prompt you for the main location, similar to this:

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

`chef analyze capture` will then scan that path, looking for the cookbooks that it needs. If all cookbooks are found, it will finish; but if any are missing, it will prompt individually.

### Locating Individual Cookbook Checkouts

Suppose that your node requires 5 cookbooks:

  - cron (v1.6.1)
  - chef-client (v4.3.0)
  - logrotate (v1.9.2)
  - windows (v1.44.1)
  - chef_handler (v1.4.0)

But only `cron` and `chef-client` are present in the directory you provided in the initial prompt. `chef analyze capture` will now prompt you for the remaining three:

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

If you do not have access to the original version-controlled source of a cookbook, press return at the prompt and `chef analyze capture` will use a copy of the cookbook downloaded from the Chef Server.

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

## Construct the Policyfile
Next, we need to obtain a set of attributes and the run list for the node. We also need to check the environment and roles for additional information.

Generally speaking, you would be creating a Policyfile that applies to multiple nodes, replacing a role or environment pattern.

### Create a Policyfile
If you have a Policyfile for the node, continue on. Otherwise, start by generating a policyfile with a name you select:
```
$ cd node-MYNODE-repo
$ cd policyfiles
$ chef generate policyfile my-policy
```

The policyfile my-policy.rb now has the basics in place. You need to add the specifics for the node.

### Examine the node
Run
```
	$ chef exec knife node show MYNODE -F json
{
  "name": "MYNODE",
  "chef_environment": "prod",
  "run_list": [
    "recipe[chef-client]",
    "recipe[splunk]",
    "role[superfly]"
  ],
  "normal": {
    "tags": [
    ]
  }
}
```
This tells us several things. First, we have the basics of our runlist.  The first two entries should be added directly to the Policyfile runlist. We also see that there is a role being applied; we need to examine the role `superfly` to check for any additional runlist entries and append them to the Policyfile runlist.  The role may also have attributes. In this document, we will explore the strategy of merging attributes from roles an environment into Policyfiles; other strategies are possible.

We also see that the node is a member of the prod environment. We'll come back to that later.

### Examine the Role
Run
```
$ chef exec knife role show superfly -F json
{
  "name": "superfly",
  "description": "superfly BASELINE",
  "json_class": "Chef::Role",
  "default_attributes": {
    "superfly": {
      "extra_tags": [
        "superfly"
      ]
    }
  },
  "override_attributes": {
  },
  "chef_type": "role",
  "run_list": [
  ],
  "env_run_lists": {
  }
}
```

From this we see that the role in fact has an empty runlist, so there is nothing to append to the Policyfile runlist.

However, there are default attributes present in the role. So, add those default attributes to the Policyfile.  If there were override attributes, they would be added as well.
For example:

```
# In my-policy.rb
default['superfly']['extra_tags'] = ['superfly']
```

### Examine the environment
Similarly, examine the environment, and merge in the attributes.

Run
```
$ chef exec knife environment show prod -F json
```

### Add the Cookbook List
Using the report from the step `chef analyze report nodes`, add the list of cookbooks to the Policyfile.
```
# In my-policy.rb
cookbook "chef-client"
cookbook "splunk"
```

## Converge Locally

{{< note >}}
Be cautious when running your cookbooks locally. It is possible to accidentally impact production infrastructure based on settings in your cookbooks and attributes. Read over your cookbooks and attributes, especially attributes being set in roles and environments.  If needed, override attributes to be appropriate for local testing in your `kitchen.yml`.
{{< /note >}}

### Attempt a Converge and Check for Errors

Run, in the `node-MY_NODE-repo` directory:
```
$ chef exec kitchen converge
```
Watch for Chef Infra errors. If any occur, fix them.  Also consider running cookstyle (see below). Repeat as needed.

### Run CookStyle
To check for version upgrade issues, run:
```
$ chef exec cookstyle cookbooks/some-cookbook
```
Repeat this process for each cookbook that the node consumes.

## Correct any Cookbook Style Issues
### Using auto-correct
To auto-correct cookbook issues, run:
```
$ chef exec cookstyle -a cookbooks/some-cookbook
```
Other issues may require manual intervention and editing.
Repeat this process for each cookbook that the node consumes.

### Using the VSCode Plugin
While any editor can be used, the Chef Infra extension for Visual Studio Code features several code generators and helpful features, such as running cookstyle when recipes are saved.

## Check for Data Bags
If data bags are used, you will need a `data_bags` directory in your repo.
Pull down the data_bags by running:
```
$ chef exec knife download data_bags
```

## Check for Server Searches
Check your cookbook code for Chef Infra Server searches, which will not be possible in an Effortless context. Identify locations making search calls and replace with other mechanisms of service discovery.
```
$ grep 'search(' -rn cookbooks
```

## Make a Plan File
Run:
```
$ hab plan init
```
Edit the file, `habitat/plan.sh`, (or `plan.ps1`) with the following contents:
```
pkg_name=<NAME FOR YOUR POLICYFILE>
pkg_origin=<YOUR ORIGIN>
pkg_version="0.1.0"
pkg_maintainer="YOUR NAME AND EMAIL"
pkg_license=("Apache-2.0")
pkg_scaffolding="chef/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="<YOUR POLICYFILE NAME>"
```

## Update default.toml configuration
The Effortless package will consume the data content held within habitat/default.toml for runtime options of the Chef Infra client.  While most configurations within this file are optional, `[chef_license]\acceptance` is required to be present for operation.

```
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

[chef_license]
acceptance = "undefined"

#######################################
# Optional settings
#######################################

# You don't usually need to change these.
# This project provides highly tuned defaults for you.
# If you don't have a strong reason for overriding these
# Then it's a good idea to remove them.
interval = 1800
splay = 1800
splay_first_run = 0
run_lock_timeout = 1800
log_level = "warn"
env_path_prefix = "/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"
ssl_verify_mode = ":verify_peer"

[automate]
enable = false
server_url = "https://<automate_url>/data-collector/v0/"
token = "<automate_token>"
# The connection information for your Chef Automate server
# Setting enable = false will turn off this feature
# The server_url is the url to your Chef Automate Server
# The token is a token with the data_collector rights to the Chef Automate API
# Default value: false

#######################################
# End of optional settings
#######################################
```

## Build the Package
Before you build, make sure you have a tree that looks like:
```
$ tree
├── cookbooks
│   ├── some-cookbook/
│   └── another-cookbook/
├── habitat
│   ├── default.toml
│   └── plan.sh
├── policyfiles
│ └── my-policy.rb
└── .kitchen.yml
```

Run
```
$ hab pkg build habitat
```

A file ending in .hart should now exist in results/ .

## Deploy the Package to the Target Machine
Publish the .hart file to Builder by running on your development workstation:
```
$ . results\last_build.env (or ps1)
$ hab pkg upload $pkg_artifact --channel mychannel
```
Infra clients can now pull down the latest file using:
```
$ hab pkg install my-origin/my-policy
$ hab svc load my-origin/my-policy
```
