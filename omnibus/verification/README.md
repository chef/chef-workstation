# What is this?

We migrated `chef verify` out of the Chef CLI and into a script that can be ran by our CI system. The CI system should
run something like:

* `C:/opscode/chef-workstation/embedded/bin/ruby.exe omnibus/verification/run.rb --unit`
* `/opt/chef-workstation/embedded/bin/ruby omnibus/verification/run.rb --unit`

This will run the validation on the full suite of components included inside Chef Workstation. New components can be
added to `omnibus/verification/verify.rb` following existing patterns there.

## What is in the spec folder?

The spec folder contains tests for the `verify.rb` functionality. It tests the tester.
