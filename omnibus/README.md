# Chef Workstation Omnibus project

This project creates full-stack platform-specific packages for Chef Workstation

## Overview

We use Omnibus to describe our packaging. [Expeditor](https://expeditor.chef.io/docs/getting-started/) manages triggering builds, promotions and other common tasks.

The build pipeline generally looks like the following:

1. User opens a PR. Unit tests run in Buildkite. Reviews occur in GitHub.
1. When the PR is merged Expeditor takes over. It runs the list of tasks we have specified in `.expeditor/config.yml`.
1.1. These tasks include things like automatically bumping versions, updating the changelog, kicking off builds in Buildkite, etc. Look at the config file for the current list of [actions](https://expeditor.chef.io/docs/reference/built_in/).
1.1. The Buildkite build pipeline is configured in `.expeditor/release.omnibus.yml`
1. Notifications from Expeditor will be posted in Chef's internal slack to #chef-ws-notify (also configured in `.expeditor/config.yml`). Any failures will need to be addressed.
1. Builds are automatically placed in the `unstable` channel when first built and automatically promoted by Buildkite to the `current` channel when they pass their test phase in the pipeline.
1. To promote to the `stable` channel (also called 'releasing') we use Expeditor.
1.1. `/expeditor promote chef/chef-workstation:master 1.0.2` would promote a 1.0.2 build from current to stable.
1. Packages are available via...
1.1. mixlib-install, omnitruck, downloads.chef.io, Habitat Depot, Dockerhub
1. Come to `#releng-support` if any of these things cause issues

## Installation

You must have a sane Ruby environment with Bundler installed. Ensure all the required gems are installed:

```shell
$ cd omnibus
$ bundle install --binstubs
```

## Usage

### Build

You create a platform-specific package using the `build project` command:

```shell
$ sudo bin/omnibus build chef-workstation
```

The platform/architecture type of the package created will match the platform where the `build project` command is invoked. For example, running this command on a MacBook Pro will generate a macOS package. After the build completes packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with the `clean` command:

```shell
$ bin/omnibus clean chef-workstation
```

Adding the `--purge` purge option removes **ALL** files generated during the build including the project install directory (`/opt/chef-workstation`) and the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean chef-workstation --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such as Amazon S3 and Artifactory. You must set the proper credentials in your `omnibus.rb` config file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the `help` command:

```shell
$ bin/omnibus help
```

## Kitchen-based Build Environment

Every Omnibus project ships will a project-specific [Berksfile](https://docs.chef.io/berkshelf.html) that will allow you to build your omnibus projects on all of the projects listed in the `kitchen.yml`. You can add/remove additional platforms as needed by changing the list found in the `kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However, there is nothing that restricts you to building on other platforms. Simply use the [omnibus cookbook](https://github.com/chef-cookbooks/omnibus) to setup your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local development. Test Kitchen also exposes the ability to provision instances using various cloud providers like AWS, DigitalOcean, or OpenStack. For more information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `kitchen.yml` (or `kitchen.local.yml`) to your liking, you can bring up an individual build environment using the `kitchen` command.

```shell
$ bin/kitchen converge ubuntu-1804
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1804
[vagrant@ubuntu...] $ . ~/load-omnibus-toolchain.sh
[vagrant@ubuntu...] $ cd chef-workstation/omnibus
[vagrant@ubuntu...] $ bundle install --without development # Don't install dev tools!
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build chef-workstation
```

For a complete list of all commands and platforms, run `kitchen list` or `kitchen help`.

## License

```text
Copyright 2012-2019, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
