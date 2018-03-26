#
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
#

require "chef-workstation/command/base"
require "chef-workstation/command/config"
require "chef-workstation/config"
require "toml-rb"

module ChefWorkstation
  module Command
    class Config
      class Show < ChefWorkstation::Command::Base

        def run(params)
          d = ChefWorkstation::Config.using_default_location? ? "default " : ""
          puts Text.commands.config.show.source(d, ChefWorkstation::Config.location)
          puts TomlRB.dump(ChefWorkstation::Config.hash_dup)
        end

      end
    end
  end
end
