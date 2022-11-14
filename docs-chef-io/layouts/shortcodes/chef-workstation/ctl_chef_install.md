Use the `chef install` subcommand to evaluate a Policyfile and find a
compatible set of cookbooks, build a run-list, cache it locally, and
then emit a `Policyfile.lock.json` file that describes the locked policy
set. The `Policyfile.lock.json` file may be used to install the locked
policy set to other machines and may be pushed to a policy group on the
Chef Infra Server to apply that policy to a group of nodes that are
under management by Chef.

<div class="admonition-note">

<p class="admonition-note-title">Note</p>

<div class="admonition-note-text">

By default, the cookbook cache is located in `~/.chef-workstation`
on macOS and Linux, and in `%LOCALAPPDATA%\chef-workstation` on Windows.
On macOS or Linux, set the desired location of the cache directory by setting the `CHEF_WORKSTATION_HOME`
environment variable in your `.bashrc` or `zshrc` file. For example, `CHEF_WORKSTATION_HOME="~/.workstation"`.
On Windows, use the `setx` [command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/setx)
or access the [Advanced](https://support.microsoft.com/en-us/topic/how-to-manage-environment-variables-in-windows-xp-5bf6725b-655e-151c-0b55-9a8c9c7f747d)
tab in System Properties to set the `CHEF_WORKSTATION_HOME` environment variable.
</div>

</div>