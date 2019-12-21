#
# Copyright:: 2019 Chef Software, Inc.
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
dependency "rubygems"

build do
  block "Removing additional non-code files from installed gems" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr('\\', "/")
    files = %w{
      .github
      .kokoro
      Appraisals
      ARCHITECTURE.md
      autotest/*
      bench
      benchmark
      benchmarks
      CHANGELOG
      CHANGELOG.md
      CHANGELOG.rdoc
      CHANGELOG.txt
      CHANGES
      CHANGES.md
      CHANGES.txt
      Code-of-Conduct.md
      CODE_OF_CONDUCT.md
      CONTRIBUTING.md
      CONTRIBUTING.rdoc
      CONTRIBUTORS.md
      doc
      doc-api
      docs
      donate.png
      ed25519.png
      example
      examples
      ext
      FAQ.txt
      Gemfile.devtools
      Gemfile.lock
      Gemfile.travis
      GUIDE.md
      HISTORY
      HISTORY.md
      History.rdoc
      HISTORY.txt
      INSTALL
      ISSUE_TEMPLATE.md
      logo.png
      man
      Manifest
      Manifest.txt
      MIGRATING.md
      rakelib
      README
      README-json-jruby.md
      README.markdown
      README.md
      README.rdoc
      README.txt
      README.YARD.md
      README_INDEX.rdoc
      release-script.txt
      sample
      samples
      site
      test
      tests
      TODO
      TODO.md
      travis_build_script.sh
      UPGRADING.md
      warning.txt
      website
    }

    Dir.glob(Dir.glob("#{target_dir}/*/{#{files.join(",")}}")).each do |f|
      puts "Deleting #{f}"
      if File.directory?(f)
        # recursively removes files and the dir
        FileUtils.remove_dir(f)
      else
        File.delete(f)
      end
    end
  end
end
