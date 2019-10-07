# Top-level `chef` wrapper

This top-level command gives us full control of our tooling inside the
Chef ecosystem, we are able to integrate and modularize multiple tools
in a single place and make the `chef` command a first citizen of our
development experience.

### Related Resources
Design Proposal (GH Issue): https://github.com/chef/chef-workstation/issues/497

## Development

As a requirement, you need to [Install Habitat](https://www.habitat.sh/docs/install-habitat/)
on your workstation since we use the [Habitat Studio](https://www.habitat.sh/docs/glossary/#glossary-studio)
as our development environment for this tool.

After installing Habitat, enter the studio from the root of this repository
and run the helper method `build_cross_platform` which will do a cross-platform
compilation of this tool:
```
$ cd chef-workstation/
$ hab studio enter
[1][default:/src:0]# build_cross_platform
Number of parallel builds: 3

-->     linux/amd64: _/src/components/main-chef-wrapper
-->     windows/386: _/src/components/main-chef-wrapper
-->    darwin/amd64: _/src/components/main-chef-wrapper
-->      darwin/386: _/src/components/main-chef-wrapper
-->       linux/386: _/src/components/main-chef-wrapper
-->   windows/amd64: _/src/components/main-chef-wrapper
```

Find all the compiled binaries inside the `bin/` directory:
```
[2][default:/src:0]# ll bin/
total 13140
-rwxr-xr-x 1 root root 2066756 Oct  7 21:16 chef_darwin_386
-rwxr-xr-x 1 root root 2322104 Oct  7 21:16 chef_darwin_amd64
-rwxr-xr-x 1 root root 2070971 Oct  7 21:16 chef_linux_386
-rwxr-xr-x 1 root root 2338292 Oct  7 21:15 chef_linux_amd64
-rwxr-xr-x 1 root root 2184704 Oct  7 21:16 chef_windows_386.exe
-rwxr-xr-x 1 root root 2463232 Oct  7 21:16 chef_windows_amd64.exe
```
