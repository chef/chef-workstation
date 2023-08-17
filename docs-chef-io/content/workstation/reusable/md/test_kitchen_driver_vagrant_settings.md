The following attributes are used to configure `kitchen-vagrant` for
Chef:

`box`

: The box on which Vagrant will run.

: Default value: computed from the platform name of the instance.

: Required

`box_check_update`

: Whether to check for box updates.

: Default value: `false`.

`box_url`

: The URL at which the configured box is located.

: Default value: computed from the platform name of the instance, but only when the Vagrant provider is VirtualBox- or VMware-based.

`communicator`

: Use to override the `config.vm.communicator` setting in Vagrant. For example, when a base box is a Windows operating system that does not have SSH installed and enabled, Vagrant will not be able to boot without a custom Vagrant file.

: Default value: `nil` (assumes SSH is available).

`customize`

: A hash of key-value pairs that define customizations that should be made to the Vagrant virtual machine.

  Example: `customize: memory: 1024 cpuexecutioncap: 50`.

`guest`

: The `config.vm.guest` setting in the default Vagrantfile.

`gui`

: The graphical user interface for the defined platform. This is passed to the `config.vm.provider` setting in Vagrant, but only when the Vagrant provider is VirtualBox- or VMware-based.

`network`

: An array of network customizations to be applied to the virtual machine.

  Example: `network: - ["forwarded_port", {guest: 80, host: 8080}] - ["private_network", {ip: "192.168.33.33"}]`.

: Default value: `[]`. 

`pre_create_command`

: A command to run immediately before `vagrant up --no-provisioner`.

`provider`

: The Vagrant provider. This value must match a provider name in Vagrant.

`provision`

: Whether to provision Vagrant when the instance is created. This is useful if the operating system needs customization during provisioning.

: Default value: `false`.

`ssh_key`

: The private key file used for SSH authentication.

`synced_folders`

: The collection of synchronized folders on each Vagrant instance. Source paths are relative to the Kitchen root path.

  Example: `synced_folders: - ["data/%{instance_name}", "/opt/instance_data"] - ["/host_path", "/vm_path", "create: true, type: :nfs"]`.

: Default value: `[]`.

`vagrantfile_erb`

: The alternate Vagrant Embedded Ruby (ERB) template to be used by this driver.

`vagrantfiles`

: An array of paths to one (or more) Vagrant files to be merged with the default Vagrant file. The paths may be absolute or relative to the kitchen.yml file.

`vm_hostname`

: The internal hostname for the instance. This is not required when connecting to a Vagrant virtual machine. Set this to `false` to prevent this value from being rendered in the default Vagrantfile.

: Default value: computed from the platform name of the instance.
