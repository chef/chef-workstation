# TODO rename file, component, repo
name "chef-workstation-app"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"

source git: "https://github.com/chef/chef-workstation-tray"
default_version "mp/revamp-packaging"

build do
  block "do_build" do

    app_version = JSON.parse(File.read(File.join(project_dir, "package.json")))["version"]

    env = with_standard_compiler_flags(with_embedded_path)
    platform_name, artifact_name = if mac_os_x?
                                     ["mac", "Chef Workstation App-#{app_version}-mac.zip"]
                                   elsif linux?
                                     ["linux", "linux-unpacked"]
                                   elsif windows?
                                     ["win", "Chef Workstation App-#{app_version}-win.zip"]
                                   end
    separator = File::PATH_SEPARATOR || ":"
    installer_dir = "#{install_dir}/installers"

    dist_dir = File.join(project_dir, "dist")
    delete dist_dir

    artifact_path = File.join(dist_dir, artifact_name)
    path_key = windows? ? "Path" : "PATH"
    # NOTE: This is set in the nodejs-binary software definition, whether or not it extracts.
    # This allows us to use the binaries from the extraction path without having to temporarily
    # copy them into our installation.
    node_tools_dir = ENV['omnibus_nodejs_bindir']
    node_bin_path = File.join(node_tools_dir, "bin")
    env[path_key] = "#{env[path_key]}#{separator}#{node_bin_path}"


    npm_bin = File.join(node_bin_path, "npm")
    command "#{npm_bin} install", env: env
    command "#{npm_bin} run-script build-#{platform_name}", env: env

    mkdir installer_dir

    if linux?
      # For linux we're using directories - electron-builder's packageer
      # fails on RHEL because of bad GLIBC version for electron-builder's
      # included compression utilities (7z, tar, etc)
      # We'll manually create this archive as part of the build for linux.
      target = File.join(installer_dir, "chef-workstation-app-#{platform_name}.tar.gz")
      command "tar -f #{target} -C #{artifact_path} -cz .", env: env
    else
      target = File.join(installer_dir, "chef-workstation-app-#{platform_name}.zip")
      copy artifact_path, target
    end
  end
end
# TODO cleanup step that removes node binaries so they're not packaged.
