#
# Copyright 2018 Chef Software, Inc.
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

name "chef-workstation-release-notes"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"

source git: "https://github.com/chef/chef-workstation.wiki"

# We maintain our release notes in a separate repo from chef-workstation today. When
# Chef Workstation is released the notes are pushed to a public S3 bucket. We will
# eventually have a release notes service read that and host public release notes
# viewable online. We still want to bundle the release notes inside the package
# for users with an airgapped workstation.
default_version "master"

if linux?
  whitelist_file(/components\/chef-workstation-release-notes\/Stable-Release-Notes\.md/)
end

build do
  release_notes_dir = File.join(install_dir, "components", "chef-workstation-release-notes")
  mkdir release_notes_dir
  release_notes = File.join(release_notes_dir, "Stable-Release-Notes.md")
  copy File.join(project_dir, "Stable-Release-Notes.md"), release_notes
end
