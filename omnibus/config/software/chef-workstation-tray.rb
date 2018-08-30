# TODO rename file, component, repo
name "chef-workstation-tray"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"
dependency "nodejs-binary"

# TODO - rename the repo  to chef-workstation-app
source git: "https://github.com/chef/chef-workstation-tray"
# TODO - master
default_version "mp/revamp-packaging"

build do
  block "do_build" do
    app_version = JSON.parse(File.read(File.join(project_dir, "package.json")))["version"]

    env = with_standard_compiler_flags(with_embedded_path)
    platform_name, artifact_path = if mac_os_x?
                                     ["mac", "Chef Workstation App-#{app_version}-mac"]
                                   elsif linux?
                                     # For linux we're using directories - electron's packageer
                                     # fails on RHEL because of bad GLIBC version.
                                     # Instead we'll manually create an archive for linux platforms.
                                     #
                                     ["linux", "chef-workstation-app-#{app_version}"]
                                   elsif windows?
                                     ["win", "Chef Workstation App-#{app_version}-win"]
                                   end
    separator = File::PATH_SEPARATOR || ":"
    node_bin_path = File.join(install_dir, "embedded", "nodejs", "bin")
    installer_dir = "#{install_dir}/installers"
    dist_dir = File.join(project_dir, "dist")

    env["PATH"] = "#{env["PATH"]}#{separator}#{node_bin_path}"
    # Windows
    env["Path"] = "#{env["Path"]}#{separator}#{node_bin_path}"

    FileUtils.rm_rf(dist_dir)
    command "npm install", env: env
    command "npm run-script build-#{platform_name}", env: env

    mkdir installer_dir

    if linux?
      target = File.join(installer_dir, "chef-workstation-app-#{platform_name}.tar.gz")
      command "tar -f #{target} -C dist/linux-unpacked -cz .", env: env
    else
      target = File.join(installer_dir, "chef-workstation-app-#{platform_name}.zip")
      copy File.join(dist_dir, artifact_path), target
    end
  end
end
# TODO cleanup step that removes node binaries so they're not packaged.
