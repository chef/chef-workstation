+++
title = "About Chef Workstation"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    weight= "30"
+++

Start your infrastructure automation quickly and easily with Chef Workstation.
Chef Workstation gives you everything you need to get started with Chef &#8212; ad hoc
remote execution, remote scanning, configuration tasks, cookbook creation tools
as well as robust dependency and testing software &#8212; all in one easy-to-install
package.

Chef Workstation replaces ChefDK, combining all the existing features with
new features, such as ad-hoc task support and the new Chef Workstation desktop
application. Chef will continue to maintain ChefDK, but new development will
take place in Chef Workstation without backporting features.

## Open Source

We're keeping the tradition of open source development in Chef. You'll find the
Chef Workstation source code on
[GitHub](https://github.com/chef/chef-workstation). We're releasing Chef
Workstation under the open source [Apache 2.0
license](https://github.com/chef/chef-workstation/blob/master/LICENSE).

### Contributing to Chef Workstation

We always welcome (and deeply appreciate!) new contributions to the project.
The best way to start contributing to Chef Workstation is to provide us with
in-depth feedback by creating GitHub issues.

See the [Community Contribution Guidelines](https://docs.chef.io/community_contributions.html)
and our [community guidelines](https://docs.chef.io/community_guidelines.html) for
keeping the development of the project awesome for all contributors.

## Supported Platforms

Supported Host Operating Systems:

| Platform                         | Version  |
| -------------                    | -----:|
| Apple macOS                      | 10.11, 10.12, 10.13|
| Microsoft Windows                | 10, Server 2008 R2, Server 2012, Server 2012 R2, Server 2016 |
| Red Hat Enterprise Linux / CentOS| 6.x, 7.x |
| SUSE Enterprise Linux Server     | 11 SP4, 12 SP1+ |
| Ubuntu                           | 14.04, 16.04, 18.04 |
| Debian                           | 7.x, 8.x, 9.x |

Supported Target Operating Systems:

| Platform                         | Version  |
| -------------                    | -----:|
| Microsoft Windows                | 10, Server 2008 R2, Server 2012, Server 2012 R2, Server 2016 |
| Red Hat Enterprise Linux         | 6.x, 7.x |
| SUSE Enterprise Linux Server     | 11 SP4, 12 SP1+ |
| Ubuntu                           | 14.04, 16.04, 18.04 |
| Debian                           | 7.x, 8.x, 9.x |

## System Requirements

### Chef Workstation

#### Minimum

* RAM: 2GB
* Disk: 4GB
* Running minimum settings may limit your ability to take advantage of Chef
  Workstation tools such as Test Kitchen which creates and manages virtualized
  test environments.

#### Recommended

* RAM: 4GB
* Disk 8GB

#### Chef Workstation App

* Windows: No additional requirements
* Mac: No additional requirements
* Linux:
  * You must have a graphical window manager running
  * Additional libraries may be required. See [Running the Chef Workstation App]({{< ref "chef-workstation-app.md#linux" >}})
    for more details.
