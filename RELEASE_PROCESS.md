# Releasing Chef Workstation

This document describes the release process for Chef Workstation.

The general overview is:

1. Ensure build pipeline is green and `current` channel builds are being generated
1. Merge any pending PRs
1. Write release notes
1. Have release notes reviewed by the docs team
1. Perform the release

Chef Workstation is released every two weeks. Monday at sprint kickoff the goal is to identify the target version to be released (including any pending dependency updates). Release notes should be generated that day, or ASAP, and provided to the docs team for review. The desired date for performing the release is Wednesday, three days into the sprint.

## Build Pipeline

The build pipeline should always be kept in a 'green' state. Each PR merged to main should pass its [verify](https://buildkite.com/chef/chef-chef-workstation-main-verify) tests. After a PR is merged, ensure the [build](https://buildkite.com/chef/chef-chef-workstation-main-omnibus-release) pipeline is successful and promotes the build to the `current` channel.

## Merge Pending PRs

Examine the [open PRs](https://github.com/chef/chef-workstation/pulls) on the Chef Workstation repo and determine if any should be merged for the upcoming release.

Dependabot and Expeditor are configured to create PRs when dependent packages are updated. Those processes can sometimes fail or there may be a pending PR in a dependent package that should be merged. Check the following repos and ensure they have the desired PRs merged, released, and updated in Chef Workstation:

* [Chef Workstation App](https://github.com/chef/chef-workstation-app)
* [Chef CLI](https://github.com/chef/chef-cli)
* [Chef Analyze](https://github.com/chef/chef-analyze/)
* [Chef Infra Client](https://github.com/chef/chef/)
* [InSpec](https://github.com/inspec/inspec/)
* [Test Kitchen](https://github.com/test-kitchen/test-kitchen/) and its drivers

Check with the teams responsible for these dependencies to see if they have any updates they want to get in the upcoming release. Also check with the #eng-infra-chef team (responsible for Chef Infra development) to see if they have any PRs they want merged before release.

Finally, run a `bundle update` on the `omnibus` and `components/gems` folders to see if there are any random dependencies that can be updated.

## Write Release Notes

Release notes should be written in the [wiki](https://github.com/chef/chef-workstation/wiki/Pending-Release-Notes). The template is a guide but it is often useful to look at existing release notes in [discourse](https://discourse.chef.io/search?expanded=true&q=Chef%20Workstation%20%23chef-release%20order%3Alatest) for examples of the format and what should be included.

To see changes that have occurred since the last release, run `git difftool -d 21.8.555` and supply the last released version. This can also be done in the browser by accessing https://github.com/chef/chef-workstation/compare/21.8.555...main and providing the last released version. This is helpful for seeing PRs that have updated code in the Chef Workstation repo. Changes to `omnibus_overrides.rb` should be looked for first.

The bulk of the release note content comes from the `components/gems/Gemfile.lock` file. This shows all the dependencies that have updated. Generally, patch level dependency updates are not included in the release notes. Any minor/major level updates to Chef maintained gems should be included in the release notes, as well as updates to security related gems (IE, OpenSSL).

## Release Notes Review

Drop a note in the `#docs-support` Slack channel and ask for a review of the [release notes](https://github.com/chef/chef-workstation/wiki/Pending-Release-Notes). Docs team has up to 3 days to review the release notes.

Ask the Inspec and Chef Infra developers for review as well. They often have insight into what should be announced or not.

## Perform the Release

In slack, run the `/expeditor promote chef-workstation 20.10.168` and supply the desired `current` channel package to promote. This will kick off the release process. Watch for notifications in the `#chef-ws-notify` channel for any build failures.

### Common Failures

Sometimes the Omnitruck cache takes a long time to refresh. If you run `curl 'https://omnitruck.chef.io/stable/chef-workstation/metadata?p=mac_os_x&pv=11&m=x86_64&v=latest'` and it does not return the version you just promoted, the omnitruck cache has not been updated. Run this periodically (it can sometimes take a few hours) and retry the failed portion of the promote process after the correct version is returned. Retries can be performed on the Expeditor messages in `#chef-ws-notify`.

The released package is also uploaded to Homebrew and Chocolatey via a triggered [third party packages](https://buildkite.com/chef/chef-chef-workstation-main-third-party-packages) pipeline. This often fails if the Omnitruck cache is slow to update. Continue retrying the Chocolatey pipeline after Omnitruck has refreshed and it should eventually succeed.

As of the writing of this document, the Homebrew job is broken. To manually create the Homebrew PR take the following steps:

1. Clone the https://github.com/homebrew/homebrew-cask repo and ensure it is up to date
1. Add https://github.com/chef/homebrew-cask as a new remote
1. Update the `Casks/chef-workstation.rb` with the new version and SHA
1. Push this change to a branch on the Chef fork
1. Open a PR against the original repo with the updated cask
1. Perform the PR checklist to ensure it will pass the tests on their side
1. The Homebrew team will merge the PR
