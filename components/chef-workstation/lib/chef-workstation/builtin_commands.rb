# Copyright:: Copyright (c) 2018 Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "chef-workstation/commands_map"
require "chef-workstation/text"

text = ChefWorkstation::Text.commands

ChefWorkstation.commands do |c|
  # TODO must be a better API we can do than `top_level` and `create`
  c.top_level("target", :Target, text.target, "chef-workstation/command/target", subcommands: [
    c.create("converge", [:Target, :Converge], text.target.converge, "chef-workstation/command/target/converge", cmd_alias: "converge" ),
  ])

  c.top_level("config", :Config, text.config, "chef-workstation/command/config", subcommands: [
    c.create("show", [:Config, :Show], text.config.show, "chef-workstation/command/config/show"),
  ])
  # TODO - Can we implement this allow us to specify
  #        relative ordering? 'help' and 'version' should
  #        always be last.

  # This exists so that 'help' shows as a subcommand.
  # Help is a function of a command, so we convert the subcommand 'help' to the appropriate
  # flag when we encounter it and pass it into the actual command that the
  # customer wants to execute. It is never instantiated.
  c.top_level("help", nil, text.base, nil)

  # Version works inversely - if someone specifies '-v' we will swap that out
  # to use the Version command.
  c.top_level("version", :Version, text.version, "chef-workstation/command/version")

  # This is our root command 'chef'. Giving it all top-level subcommands (which will
  # exclude this hidden one at time of evaluation) means that 'chef help' will be able to show
  # the subcommands.
  #
  # TODO: In another pass, let's get rid of 'hidden-root' and make CommandMap support a root node.
  c.top_level("hidden-root", :Base, text.base, "chef-workstation/command/base",
              hidden: true, subcommands: c.command_specs.values)
end
