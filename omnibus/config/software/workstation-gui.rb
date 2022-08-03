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
dependency "libxml2"
dependency "libxslt"
dependency "liblzma"
dependency "zlib"
dependency "libarchive"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # bundle "package --no-install", env: env
  # This statement is to replace the --without flag which is getting deprecated
  # bundle "config set without 'development doc'"
  # exec 'brew install libxml2'
  # exec 'bundle config build.nokogiri "--use-system-libraries --with-xml2-include=/usr/local/opt/libxml2/include/libxml2"'
  bundle "package --no-install", env: env
  bundle "config local.digest 'vendor/bundle' "
  bundle "config local.websocket-driver 'vendor/bundle' "
  bundle "config local.racc 'vendor/bundle' "
  bundle "config local.strscan 'vendor/bundle' "
  bundle "config set --local path 'vendor/bundle' "

  bundle "install" \
         " --jobs #{workers}" \
         " --retry 3",
         env: env


  # This fails because we're installing Ruby C extensions in the wrong place!
  # bundle "exec rake assets:precompile", env: env # Note--> not needed as this is api only app
  gui_app_path = "#{install_dir}/embedded/service/workstation-gui/"

  # FileUtils.mkdir_p gui_app_path
  # FileUtils.cp project_dir, gui_app_path

  mkdir gui_app_path
  copy "#{project_dir}/*", gui_app_path
end
