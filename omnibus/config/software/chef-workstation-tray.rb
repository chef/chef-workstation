
name "chef-workstation-tray"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"
source git: "https://github.com/chef/chef-workstation-tray"
default_version "master"

build do
  # Use the package.json to get current version, then (for now) we'll download the installer
  # and put it in helpful place.
  # This is a temporary solution until we make final packaging/distribution decisions.
  # We run this in a block because non-DSL operations will otherwise happen before the
  # fetcher has had a chance to update the target.
  block "do_build" do
    version = File.read(File.join(project_dir, "VERSION")).chomp
    use_ext = true
    if mac_os_x?
      source_file = "chef-workstation-#{version}.dmg"
    elsif windows?
      source_file = "chef-workstation-#{version}.msi"
    else
      p = Omnibus::Packager.for_current_system.first
      if p == Omnibus::Packager::RPM
        source_file = "chef-workstation-#{version}-x86_64.rpm"
      elsif p == Omnibus::Packager::DEB
        source_file = "chef-workstation-#{version}-amd64.deb"
      else
        raise "Unexpected packager for linux: #{p}"
      end
    end
    target_dir = File.join(install_dir, "instalers")

    # Auto-follow redirects because github release artifact urls always do.
    redirect_getter = Proc.new  do |uri, fetcher|
      response = Net::HTTP.get_response(URI(uri))
      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        fetcher.call(location, fetcher)
      else
        response.value
      end
    end

    FileUtils.mkdir_p target_dir
    target_path = File.join(target_dir, "chef-tray#{use_ext ? File.extname(source_file) : ""}")
    resp = redirect_getter.call("https://github.com/chef/chef-workstation-tray/releases/download/v#{version}/#{source_file}", redirect_getter)
    File.open(target_path, "wb") { |file|  file.write(resp.body) }
    File.chmod(0755, target_path)
  end
end


# TODO build cleanup step to remove python from the package - I think it's only
# here as  a result of nodejs


