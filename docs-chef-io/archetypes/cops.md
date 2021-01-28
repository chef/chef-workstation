+++
title = "{{ .Name | humanize | title }}"
draft = false

layout = "cookstyle_cops"
data_path = ["workstation","cookstyle","{{ .Name }}"]

[menu]
  [menu.workstation]
    title = "{{ .Name | humanize | title }}"
    identifier = "chef_workstation/chef_workstation_tools/cookstyle/{{ .Name | humanize | title }}"
    parent = "chef_workstation/chef_workstation_tools/cookstyle"
+++

<!-- The contents of this page are automatically generated from the {{ .Name }}.yaml file
in the docs-chef-io/data/workstation/cookstyle directory in the chef/chef-workstation repository. -->
