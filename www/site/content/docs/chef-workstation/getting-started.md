+++
title = "Getting Started"
[menu]
  [menu.docs]
    parent = "Chef Workstation"
    Weight = "1"
+++

## Overview 

Chef Workstation gives you everything you need to get started with Chef. Ad-hoc remote execution, scans and configuration tasks, cookbook creation tools, and robust dependency and testing software all in one easy-to-install package.

## Install Chef Workstation 

If you have not installed Chef Workstation, please download and install via https://www.chef.sh. 

## Check versions 

New ad-hoc commands `chef-run` and ChefDK commands such as `chef` are available via Chef Workstation. Your output may differ if you are running different versions. 

``` 
$ chef-run -v 
chef-run: 0.1.114

$ chef -v 
Chef Development Kit Version: 3.0.36
chef-client version: 14.1.12
delivery version: master (7206afaf4cf29a17d2144bb39c55b7212cfafcc7)
berks version: 7.0.2
kitchen version: 1.21.2
inspec version: 2.1.72
```

## Ad-hoc remote execution 


