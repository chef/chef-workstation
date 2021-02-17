+++
title = "About Chef Workstation"
draft = false

gh_repo = "chef-workstation"

aliases = ["/about_workstation.html", "/about_chefdk.html", "/chef_dk.html", "/about_workstation/"]

[menu]
  [menu.workstation]
    title = "About Chef Workstation"
    identifier = "chef_workstation/about_workstation.md About Chef Workstation"
    parent = "chef_workstation"
    weight = 10
+++

{{% chef_workstation %}}

Chef Workstation replaces ChefDK, combining all the existing features
with new features, such as ad-hoc task support and the new Chef
Workstation desktop application.

## Getting Started

Chef Infra is a systems and cloud infrastructure automation framework
that makes it easy to deploy servers and applications to any physical,
virtual, or cloud location, no matter the size of the infrastructure.
Each organization is comprised of one (or more) Chef Workstation
installations, a single server, and every node that will be configured
and maintained by Chef Infra Client. Cookbooks (and recipes) are used to
tell Chef Infra Client how each node in your organization should be
configured. Chef Infra Client---which is installed on every node---does
the actual configuration.

- [An Overview of Chef Infra](/chef_overview/)
- [Install Chef Workstation](/workstation/install_workstation/)

### Cookbook Development Workflow

Chef Infra defines a common workflow for cookbook development:

1. Create a skeleton cookbook by running `chef generate cookbook MY_COOKBOOK_NAME`. This will generate a cookbook with a single recipe and testing configuration for Test Kitchen with Chef InSpec.
1. Write cookbook recipes or resources and debug those recipes as they are being written using Cookstyle and Test Kitchen. This is typically an iterative process, where cookbooks are tested as they are developed, bugs are fixed quickly, and then cookbooks are tested again. A text editor---Visual Studio Code, Atom, vim, or any other preferred text editor---is used to author the files in the cookbook.
1. Perform acceptance tests. These tests are not done in a development environment, but rather are done against using an environment that matches the production environment as closely as possible.
1. When the cookbooks pass all the acceptance tests and have been verified to work in the desired manner, deploy the cookbooks to the production environment.

## Tools

Chef Workstation packages all the tools necessary to be successful with Chef Infra and InSpec. These tools are combined into native packages for common operating systems and include all the dependencies you need to get started.

The most important tools included in Chef Workstation are:

<table>
<colgroup>
<col style="width: 12%" />
<col style="width: 87%" />
</colgroup>
<thead>
<tr class="header">
<th>Tool</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Chef CLI</td>
<td>A workflow tool for Chef Infra.</td>
</tr>
<tr class="even">
<td>knife</td>
<td>A tool for managing systems on the Chef Infra Server.</td>
</tr>
<tr class="odd">
<td>Chef Infra Client</td>
<td>The Chef Infra agent.</td>
</tr>
<tr class="even">
<td>Chef InSpec</td>
<td>A compliance as code tool that can also be used for testing Chef Infra cookbooks.</td>
</tr>
<tr class="odd">
<td>Cookstyle</td>
<td>A linting tool that helps you write better Chef Infra cookbooks by detecting and automatically correcting style, syntax, and logic mistakes in your code.</td>
</tr>
<tr class="even">
<td>Test Kitchen</td>
<td>An integration testing framework tool that tests cookbooks across platforms and various cloud provider / hypervisors.</td>
</tr>
</tbody>
</table>
