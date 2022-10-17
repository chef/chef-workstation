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

name "workstation-gui"
license :project_license

source path: File.join("#{project.files_path}", "../../src/workstation-gui")

# todo need to checkout all the dependency
dependency "ruby"
# dependency "libxml2"
# dependency "libxslt"
# dependency "liblzma"
# dependency "zlib"
# dependency "libarchive"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"

  bundle "config set --local without '#{excluded_groups.join(" ")}'", env: env

  bundle "install" \
         " --jobs #{workers}" \
         " --retry 3" \
         " --path=vendor/bundle",
         env: env

  # This fails because we're installing Ruby C extensions in the wrong place!
  # bundle "exec rake assets:precompile", env: env # Note--> not needed as this is api only app
  gui_app_path = "#{install_dir}/embedded/service/workstation-gui/"

  mkdir gui_app_path
  copy "#{project_dir}/*", gui_app_path
end
