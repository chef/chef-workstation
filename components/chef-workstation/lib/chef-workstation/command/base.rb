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

require "mixlib/cli"
require "chef-workstation/config"
require "chef-workstation/text"

module ChefWorkstation
  module Command
    class Base
      include Mixlib::CLI

      # All the actual commands have their banner managed and set from the commands map
      # Look there to see how we set this in #create
      banner "Command banner not set."

      option :help,
        :short        => "-h",
        :long         => "--help",
        :description  => Text.cli.help,
        :boolean      => true

      option :config_path,
        :short        => "-c PATH",
        :long         => "--config PATH",
        :description  => Text.cli.config(ChefWorkstation::Config.default_location),
        :default      => ChefWorkstation::Config.default_location,
        :proc         => Proc.new { |path| ChefWorkstation::Config.custom_location(path) }

      def initialize(command_spec)
        @command_spec = command_spec
        super()
      end

      def run_with_default_options(params = [])
        parse_options(params)
        if params[0]&.downcase == "help" || config[:help]
          show_help
          0
        else
          run(params)
        end
      # rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      #   raise Shak::OptionParserError.new(opt_parser.to_s)
      end

      def run(params)
        # raise Shak::UnimplementedRunError.new
        raise NotImplementedError.new
      end

      private

      def show_help
        puts banner
        unless options.empty?
          puts ""
          puts "FLAGS:"
          justify_length = 0
          options.each_value do |spec|
            justify_length = [justify_length, spec[:long].length + 4].max
          end
          options.sort.to_h.each_value do |spec|
            short = spec[:short] || "  "
            short = short[0, 2] # We only want the flag portion, not the capture portion (if present)
            if short == "  "
              short = "    "
            else
              short = "#{short}, "
            end
            flags = "#{short}#{spec[:long]}"
            puts "    #{flags.ljust(justify_length)}    #{spec[:description]}"
          end
        end
        unless subcommands.empty?
          puts ""
          puts "SUBCOMMANDS:"
          justify_length = ([7] + subcommands.keys.map(&:length)).max + 4
          subcommands.sort.each do |name, spec|
            next if spec.hidden
            puts "    #{"#{name}".ljust(justify_length)}#{spec.text.description}"
          end
        end
      end

      def subcommands
        @command_spec.subcommands
      end

    end
  end
end
