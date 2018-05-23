chef-workstation Omnibus project
====================
This project creates full-stack platform-specific packages for
`chef-workstation`!

Overview
--------

We use Omnibus to describe our packaging. [Expeditor](http://expeditor-docs.es.chef.io/) manages triggering builds, promotions and other common tasks.

The build pipeline generally looks like the following:

1. User opens a PR. Unit tests run in CircleCI. Reviews occur in Github.
1. When the PR is merge Expeditor takes over. It runs the list of tasks we have specified in `.expeditor/config.yml`.
1.1. These tasks include things like automatically bumping versions, kicking off builds in [Manhattan](http://manhattan.ci.chef.co/), etc. Look at the config file for the current list of [actions](http://expeditor-docs.es.chef.io/actions/).
1.1. The Manhattan build pipeline is configured via the [opscode-ci](https://github.com/chef-cookbooks/opscode-ci) cookbook.
1. Notifications from Expeditor will be posted in Chef's internal slack to #chef-ws-notify (also configured in `.expeditor/config.yml`). Any failures will need to be addressed.
1. Builds are automatically placed in the `unstable` channel when first built and automatically promoted by Jenkins to the `current` channel when they pass their test phase in the pipeline.
1. To promote to the `stable` channel (also called 'releasing') we use the Julia bot. Start a private message with `@julia` in Slack and type `help` for a list of help topics.
1.1. To promote join the `#releng-support` room and type `@julia artifactory promote chef-workstation 0.1.0` where `0.1.0` is the version of the build you want to promote. This promotes the artifact from the `current` channel to the `stable` channel where it is available for public consumption.
1. Packages are available via...
1.1. TODO - mixlib-install, omnitruck
1. Come to `#releng-support` if any of these things cause issues

Installation
------------
You must have a sane Ruby 2.0.0+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build chef-workstation
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean chef-workstation
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/chef-workstation`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean chef-workstation --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Version Manifest
----------------

Git-based software definitions may specify branches as their
default_version. In this case, the exact git revision to use will be
determined at build-time unless a project override (see below) or
external version manifest is used.  To generate a version manifest use
the `omnibus manifest` command:

```
omnibus manifest PROJECT -l warn
```

This will output a JSON-formatted manifest containing the resolved
version of every software definition.


Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1404
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1404
[vagrant@ubuntu...] $ . ~/load-omnibus-toolchain.sh
[vagrant@ubuntu...] $ cd chef-workstation/omnibus
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build chef-workstation
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
