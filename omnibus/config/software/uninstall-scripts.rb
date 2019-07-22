name "uninstall-scripts"

source path: "#{project.files_path}/uninstall-scripts"

skip_transitive_dependency_licensing true
license :project_license

build do
  if mac_os_x?
    copy "#{project_dir}/uninstall_chef_workstation", "#{install_dir}/bin/uninstall_chef_workstation", { preserve: true }
  end
end
