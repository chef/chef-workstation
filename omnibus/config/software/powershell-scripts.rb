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

# This is a windows only dependency

name "powershell-scripts"

skip_transitive_dependency_licensing true
license :project_license

build do
  block "Install windows powershell scripts" do
    # Copy the chef gem's distro stuff over
    chef_gem_path = File.expand_path("../..", shellout!("#{install_dir}/embedded/bin/gem which chef").stdout.chomp)

    require "erb"
    template_file = File.join("#{chef_gem_path}", "distro", "templates", "powershell", "chef", "chef.psm1.erb")
    source_ps_path = File.join("#{chef_gem_path}", "distro", "powershell", "chef")
    chef_module_dir = "#{install_dir}/modules/chef"
    create_directory(chef_module_dir)

    # Chef gem layout differs by version:
    # - Older builds ship chef.psm1.erb under distro/templates/powershell/chef
    # - Newer builds may ship pre-rendered files under distro/powershell/chef
    if File.exist?(template_file)
      template = ERB.new(File.read(template_file))
      chef_psm1 = template.result
      File.open(::File.join(chef_module_dir, "chef.psm1"), "w") { |f| f.write(chef_psm1) }
    elsif File.exist?(::File.join(source_ps_path, "chef.psm1"))
      copy_file(::File.join(source_ps_path, "chef.psm1"), chef_module_dir)
    end

    if Dir.exist?(source_ps_path)
      Dir.glob("#{source_ps_path}/*").each do |file|
        copy_file(file, chef_module_dir)
      end
    end
  end
end
