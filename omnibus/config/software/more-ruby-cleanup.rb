#
# Copyright:: Copyright Chef Software, Inc.
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

require "fileutils"

name "more-ruby-cleanup"

skip_transitive_dependency_licensing true
license :project_license

source path: "#{project.files_path}/#{name}"

dependency "ruby"

build do
  block "Removing console and setup binaries" do
    Dir.glob("#{install_dir}/embedded/lib/ruby/gems/*/gems/*/bin/{console,setup}").each do |f|
      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end

  block "remove any .gitkeep files" do
    Dir.glob("#{install_dir}/**/{.gitkeep,.keep}").each do |f|
      puts "Deleting #{f}"
      File.delete(f)
    end
  end

  block "Removing additional non-code files from installed gems" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr("\\", "/")
    files = %w{
      .rspec-tm
      .sitearchdir.time
      *-public_cert.pem
      .dockerignore
      bootstrap.sh
      ci
      diagrams
      example
      examples
      ext
      Gemfile.lock
      java
      patches
      playbooks
      perf
      rakelib
      sample
      samples
      site
      unit
      warning.txt
    }

    Dir.glob("#{target_dir}/*/{#{files.join(",")}}").each do |f|
      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end

  block "Removing Gemspec / Rakefile / Gemfile unless there's a bin dir" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr("\\", "/")
    files = %w{
      *.gemspec
      Gemfile
      Rakefile
      tasks
    }

    Dir.glob("#{target_dir}/*/{#{files.join(",")}}").each do |f|
      # don't delete these files if there's a non-empty bin dir in the same dir
      next if Dir.exist?(File.join(File.dirname(f), "bin")) && !Dir.empty?(File.join(File.dirname(f), "bin"))

      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end

  block "Removing spec dirs unless we're in components we test in the verify command" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr("\\", "/")

    Dir.glob("#{target_dir}/*/spec").each do |f|

      # don't delete these files if we use them in our verify tests
      unless File.basename(File.expand_path("..", f)).match?(/^(berkshelf|test-kitchen|chef|chef-cli|chef-apply|chefspec)-\d/)
        puts "Deleting unused spec dir #{f}"
        FileUtils.remove_dir(f)
      end
    end
  end

  # remove the chef specs we don't run as this is a large number of files
  block "Removing functional / integration / stress specs from chef" do
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems/chef-*/spec/{integration,functional,stress}".tr("\\", "/")

    Dir.glob(target_dir).each do |f|
      puts "Deleting unused spec dir #{f}"
      FileUtils.remove_dir(f)
    end
  end

  block "Remove extra unused binaries that are built with libraries we ship" do
    %w{
      xml2-config
      xmlcatalog
      xmllint
      xslt-config
      xsltproc
    }.each do |f|
      file_path = "#{install_dir}/embedded/bin/#{f}"

      if ::File.exist?(file_path)
        puts "Deleting binary at #{file_path}"
        FileUtils.rm_f(file_path)
      else
        puts "Binary #{file_path} not found. Skipping."
      end
    end
  end
end
