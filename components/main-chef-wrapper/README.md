# Top-level `chef` wrapper

This top-level `chef` command gives us full control of our tooling inside the
Chef ecosystem, we are now able to integrate and modularize multiple tools in
a single place and make the `chef` command a first citizen of our development
experience.

## (Motivation) What problem(s) are we solving?

- **Speed**: All the Ruby CLIs we have at Chef are already in a state of considerable
slowness, things like `chef -v` or just a simple `knife help` takes 10-15m to run, let
alone commands that actually do something for the user, for example, `chef export policyfile`
or `knife node list`.
    - How can we make this experience better?
    - How can we run our CLIs faster?
- **Flexibility**: There is so much we can do in Ruby land, there is also a limit on how
much can we speed up our CLIs in that language, historically at Chef we have chosen
Ruby as our main language since the core of Chef (the product) is written in Ruby and
we would like to take advantage of the core code and behavior, though, there have been
cases where we don't need to share the code and therefore, no need to use the same
language, such cases could be more efficient if we could/would use a compiled language,
but we haven't explored that path just yet. Having the ability to write our CLIs in any
language will allow us to have much more flexibility to improve all our tooling.
- **Organization**:  Another problem we are solving is the fact that, at Chef, we have
spread very wide in our toolings. We create multiple CLIs, commands, etc. that we deliver
to users in various manners, styles, and distributions, some of them are hard to identify
as a Chef tool. This work could improve the way we ship our tools and how users find
them in their system by having a single top-level command that has a list/catalog of sub-
commands (binaries) that can be run individually for better modularity and flexibility.

## Related Resources
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
