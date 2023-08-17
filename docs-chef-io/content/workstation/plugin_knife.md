+++
title = "Knife Cloud Plugins"
draft = false
gh_repo = "chef-workstation"
aliases = ["/plugin_knife.html"]
product = ["workstation"]

[menu]
  [menu.workstation]
    title = "Cloud Plugins"
    identifier = "chef_workstation/extension_apis/knife_plugins/plugin_knife.md Cloud Plugins"
    parent = "chef_workstation/extension_apis/knife_plugins"
    weight = 10
+++
<!-- markdownlint-disable-file MD033 -->

{{< readfile file="content/reusable/md/plugin_knife_summary.md" >}}

- The same [common options](/workstation/knife_options/) used by knife
    subcommands can also be used by knife plug-ins
- A knife plugin can make authenticated API requests to the Chef
    server

The following knife plug-ins are maintained by Chef:

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th>Subcommand</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><a href="https://github.com/chef/knife-azure">knife-azure</a></td>
<td>{{< readfile file="layouts/shortcodes/chef-workstation/knife_azure.md" >}}</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-ec2">knife-ec2</a></td>
<td>Amazon EC2 is a web service that provides resizable compute capacity in the cloud, based on preconfigured operating systems and virtual application software using Amazon Machine Images (AMI). The <code>knife ec2</code> subcommand is used to manage API-driven cloud servers that are hosted by Amazon EC2.</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-google">knife-google</a></td>
<td>Google Compute Engine is a cloud hosting platform that offers scalable and flexible virtual machine computing. The <code>knife google</code> subcommand is used to manage API-driven cloud servers that are hosted by Google Compute Engine.</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-openstack">knife-openstack</a></td>
<td>The <code>knife openstack</code> subcommand is used to manage API-driven cloud servers that are hosted by OpenStack.</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-rackspace">knife-rackspace</a></td>
<td>Rackspace is a cloud-driven platform of virtualized servers that provide services for storage and data, platform and networking, and cloud computing. The <code>knife rackspace</code> subcommand is used to manage API-driven cloud servers that are hosted by Rackspace cloud services</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-vcenter">knife-vcenter</a></td>
<td>The <code>knife vcenter</code> subcommand is used to provision systems with VMware vCenter.</td>
</tr>
<tr>
<td><a href="https://github.com/chef/knife-vsphere">knife-vsphere</a></td>
<td>The <code>knife vsphere</code> subcommand is used to provision systems with VMware vSphere.</td>
</tr>
</tbody>
</table>
