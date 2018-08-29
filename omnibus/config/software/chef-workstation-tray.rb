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
  app_version = JSON.parse(File.read("package.json"))["version"]

  env = with_standard_compiler_flags(with_embedded_path)
  platform_name, artifact_path = if mac_os_x?
                                   ["darwin", "Chef Workstation App-#{app_version}-mac.7z"]
                                 elsif linux?
                                   ["linux", "chef-workstation-app-#{app_version}.7z"]
                                 elsif windows?
                                   ["win", "Chef Workstation App-#{app_version}-win.7z"]
                                 end
   separator = File::PATH_SEPARATOR || ":"
   node_bin_path = File.join(install_dir, "embedded", "nodejs", "bin")
   env["PATH"] = "#{env["PATH"]}#{separator}#{node_bin_path}"

   command "npm install", env: env
   command "npm run-script build-#{platform_name}", env: env

   target = "#{install_dir}/installers/chef-workstation-app.7z"
   mkdir File.dirname(target)

   copy "#{project_dir}/dist/#{artifact_path}", "#{target}"
end

# TODO cleanup step that removes node binaries so they're not packaged.
