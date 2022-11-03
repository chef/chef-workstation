Use the `chef install` subcommand to evaluate a Policyfile and find a
compatible set of cookbooks, build a run-list, cache it locally, and
then emit a `Policyfile.lock.json` file that describes the locked policy
set. The `Policyfile.lock.json` file may be used to install the locked
policy set to other machines and may be pushed to a policy group on the
Chef Infra Server to apply that policy to a group of nodes that are
under management by Chef.

{{< note >}}

By default, the cookbook cache is located in `~/.chef-workstation`
on macOS / Linux and in `%LOCALAPPDATA%\chef-workstation` on Windows.
This can be changed by defining the `CHEF_WORKSTATION_HOME` environment
variable and setting its value to the desired cache directory.

{{< /note >}}