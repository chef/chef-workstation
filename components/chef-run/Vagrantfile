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

Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true

  def ubuntu_xenial_definition(node, name, final_octet, ssh_port)
    node.vm.box = "ubuntu/xenial64"
    node.vm.hostname = "#{name}"
    node.vm.network "private_network", ip: "192.168.33.#{final_octet}"
    node.vm.network :forwarded_port, guest: 22, host: ssh_port, id: "ssh", auto_correct: true
    node.vm.provider "virtualbox" do |v|
      # Keep these light, we're not really using them except to
      # run chef client
      v.memory = 512
      v.cpus = 1
      # Allow host caching - many images don't have it by default but it significantly speeds up
      # disk IO (such as installing chef via dpkg)
      v.customize ["storagectl", :id, "--name", "SCSI", "--hostiocache", "on"]
      # disable logging client console on host
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
  end

  config.vm.define "ubuntu1" do |node|
    ubuntu_xenial_definition(node, "ubuntu1", 51, 2221)
  end
  config.vm.define "ubuntu2" do |node|
    ubuntu_xenial_definition(node, "ubuntu2", 52, 2222)
  end
  config.vm.define "ubuntu3" do |node|
    ubuntu_xenial_definition(node, "ubuntu3", 53, 2223)
  end
  config.vm.define "ubuntu4" do |node|
    ubuntu_xenial_definition(node, "ubuntu4", 54, 2224)
  end
  config.vm.define "ubuntu5" do |node|
    ubuntu_xenial_definition(node, "ubuntu2", 55, 2225)
  end

  config.vm.define "windows1" do |node|
    node.vm.box = "chef/windows-server-2016-standard"
    node.vm.communicator = "winrm"

    # Admin user name and password
    node.winrm.username = "vagrant"
    node.winrm.password = "vagrant"

    node.vm.guest = :windows
    node.windows.halt_timeout = 15

    node.vm.network "private_network", ip: "192.168.33.61"
    node.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    node.vm.network :forwarded_port, guest: 22, host: 2231, id: "ssh", auto_correct: true

    node.vm.provider :virtualbox do |v, override|
      #v.gui = true
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
  end
end
