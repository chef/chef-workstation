#
# Copyright (c) 2018-2026 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
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
# expeditor/ignore: no version pinning

name "config_guess"
default_version "master"

# Use our GitHub mirror of the Savannah repository
source url: "https://github.com/chef/config-mirror/archive/refs/heads/master.tar.gz",
       sha256: "cc60204d0b512cfd86eca96c079b48494495c5b7937c873b708cce81ca52dc2d" # Replace with the actual checksum
internal_source url: "https://github.com/chef/config-mirror/archive/refs/heads/master.tar.gz",
       sha256: "cc60204d0b512cfd86eca96c079b48494495c5b7937c873b708cce81ca52dc2d"

# versions_list: https://github.com/chef/config-mirror/tags filter=*.tar.gz

# http://savannah.gnu.org/projects/config
license "GPL-3.0 (with exception)"
license_file "config.guess"
license_file "config.sub"
skip_transitive_dependency_licensing true

relative_path "config-mirror-#{version}"

build do
  mkdir "#{install_dir}/embedded/lib/config_guess"

  copy "#{project_dir}/config.guess", "#{install_dir}/embedded/lib/config_guess/config.guess"
  copy "#{project_dir}/config.sub", "#{install_dir}/embedded/lib/config_guess/config.sub"
end
