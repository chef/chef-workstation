+++
title = "chef-run Guide"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight = "999"
+++

# Using `chef-run`

This document covers some common usage scenarios for `chef-run`

To start with, familiarize yourself with `chef-run`'s arguments and flags
by running `chef-run -h`.

## Apply a Resource to a Single Node over SSH

In its simplest form, `chef-run` targets a single machine and execute a single
resource on that machine:

```bash
chef-run ssh://my_user@host1:2222 directory /tmp/foo --identity-file ~/.ssh/id_rsa
```

SSH is the default protocol. When using SSH, `chef-run` attempts to read defaults
from your `~/.ssh/config` file. Given the following SSH configuration:

```text
Host host1
  IdentityFile /Users/me/.ssh/id_rsa
  User my_user
  Port 2222
```

You could specify the `chef-run` command as:

```bash
chef-run host1 directory /tmp/foo
```

To use password authentication instead of an identity file, specify the
password as part of the connection information or by using the command line
flag:

```bash
chef-run my_user:a_password@host1:2222 directory /tmp/foo
chef-run my_user@host1:2222 directory /tmp/foo --password a_password
```

## Applying a Resource to a Single Node over WinRM

To target WinRM you must specify the `winrm` protocol as part of the connection
information:

```
chef-run 'winrm://my_user:my_p4ssword!@host' directory /tmp/foo
```

WinRM connections only support password authentication. Provide username and
password as shown in the example, or via the `--user` and `--password` flags.

HTTPS connections are supported by providing the `--ssl` flag.

`chef-run` over WinRM does not support certifcate-based authentication to
target hosts.

## Specifying resource properties and actions

All [Chef core resources](https://docs.chef.io/resource_reference.html) can be
specified on the command line. Use the `chef-run` command first, followed by
the resource type in the second place, and the resource name in the third
place. For example:

```bash
chef-run host1 group awesome_group
```

This command specifies the `group` resource with a name of `awesome_group`.
To specify properties and actions, use a `key=value` syntax:

```bash
chef-run host1 group awesome_group gid=1001
chef-run host1 user super_person gid=1001 'password=complex=p@ssword!!'
chef-run host1 user super_person action=remove
```

See the documentation for each resource to see available properties available to
customize. As shown in the previous example, you can quote the `key=value` pair
if the value contains a character that would be interpreted by the shell.

## Running a Recipe

To run a full recipe, specify a recipe using its path:

```bash
chef-run host1 /path/to/recipe.rb
chef-run host1 recipe.rb
```

If your recipe is in a cookbook you can also specify that cookbook:

```bash
chef-run host1 /cookbooks/my_cookbook/recipes/default.rb
chef-run host1 /cookbooks/my_cookbook
```

If you specify the path to the cookbook `chef-run` will execute the default
recipe from the cookbook on the target node.

`chef-run` also supports looking up your cookbook in a local cookbook
repository. Assuming you have your cookbook repository at `/cookbooks`, run:

```bash
cd /cookbooks
chef-run host1 my_cookbook
chef-run host1 my_cookbook::non_default_recipe
```

`::recipe_name` tells `chef-run` to run a recipe other than the default.
`chef-run` reads your local `~/.chef/config.rb` and looks for cookbooks in the
paths specified as `cookbook_path`. That configuration value is an array and
looks something like this:

```ruby
cookbook_path ['/path/1', '/path/b']
```

If you run `chef-run host1 my_cookbook` and the current directory does not have
a cookbook named `my_cookbook`, then `chef-run` searches the paths specified in
the `cookbook_path`. These paths are read out of your existing Chef
configuration instead of from the Chef Workstation configuration.

If the same cookbook exists in multiple `cookbook_path`s, the one from the
last path in the list will be used.

To specify the search paths as command line arguments instead of using a
configuration file, use:

```bash
chef-run host1 my_cookbook --cookbook-repo-paths '/path/1,/path/b'
```

## Configuring Cookbook Dependencies and Sources

When converging a target node `chef-run` creates a policyfile bundle that
includes the cookbook specified. If the cookbook you specified has its own
[`Policyfile.rb`](https://docs.chef.io/config_rb_policyfile.html) that will be
respected.

In your `metadata.rb` file:

```ruby
name "really_complicated"
...
depends "pretty_simple"
```

In your `Policyfile.rb` file:

```ruby
name "really_complicated"
default_source :supermarket
default_source :chef_repo, "../"

run_list "really_complicated::first"

cookbook "pretty_simple"
```

In your `recipes/first.rb`

```ruby
log "lets include some stuff"
include_recipe "pretty_simple::second"
```

Running `chef-run host1 really_complicated::first` collects all the
`really_complicated` cookbook dependencies (`pretty_simple`) first, in
preparation for converging the target node. When running on that node the
`first` recipe finds its local dependency on the `pretty_simple` cookbook and
then runs its `second` recipe.

You can specify different cookbook sources in `Policyfile.rb`, including a
private supermarket. See the [Policyfile
documentation](https://docs.chef.io/config_rb_policyfile.html) for examples.

## Connecting to Automate 2

You can configure remote nodes managed with `chef-run` to send run
information to Automate. First, [generate an auth token](https://automate.chef.io/docs/admin/#creating-a-standard-api-token).

Next, add the token to [config.toml]({{< ref "../reference/config.md#data-collector" >}}),
specifying the appropriate [url] (https://automate.chef.io/docs/data-collection/) and
[token](https://automate.chef.io/docs/api-tokens/#creating-a-standard-api-token)
for the automate server:

```toml
[data_collector]
url="https://127.0.0.1/data-collector/v0/"
token="abc123="
```

Target nodes need network access to port 443 of the Automate instance for
sending `chef-client` run information.
