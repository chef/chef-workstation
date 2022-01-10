## Release Process Summary 

There are several steps involved in promoting a current Workstation build to a stable release version. Workstation packaging and dependency bundling is done through [Omnibus](https://github.com/chef/omnibus) and release management is done through [Expeditor](https://expeditor.chef.io/docs). The relevant pipelines in [Buildkite](https://buildkite.com/chef) are required to succeed so that a build can be marked as current. These include pipelines defined for the component packages such as Chef Infra Client, Chef InSpec and Chef Habitat. The upcoming release notes are collated [here](https://github.com/chef/chef-workstation/wiki/Pending-Release-Notes).

## Post-Release Actions

These are the post-release steps executed by Expeditor-

1. Updates the [download](https://downloads.chef.io/tools/workstation) site
1. Updates the tags on [Docker Hub](https://hub.docker.com/r/chef/chefworkstation)
1. Creates a Pull-Request in [homebrew-chef](https://github.com/chef/homebrew-chef/) repo
1. Builds and uploads a [chocolately](https://community.chocolatey.org/packages/chef-workstation) package 
1. Updates the [Homebrew cask](https://formulae.brew.sh/cask/chef-workstation) definition
1. Announces the release in the [Discourse](https://discourse.chef.io/c/chef-release/) site
1. Updates release notes in the [Documentation](https://docs.chef.io/release_notes_workstation/) site
