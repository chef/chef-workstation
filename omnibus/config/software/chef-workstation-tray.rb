
name "chef-workstation-tray"
license "Apache-2.0"
skip_transitive_dependency_licensing
license_file "LICENSE"
source git: "https://github.com/chef/chef-workstation-tray"
default_version "master"

build do
  # This download the current tray app installer by querying the github API to determine
  # the most recently released version.  It places the installer in #{install_dir}/installers
  # We run this in a block because non-DSL operations will otherwise happen before the
  # fetcher has had a chance to update the target.
  block "do_build" do
    target_dir = File.join(install_dir, "installers")
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
    packager = Omnibus::Packager.for_current_system.first
    # Can't use 'case' here - 'packager' is a class and not an instance,
    # so it will always compare 'Class'
    package_type = if packager == Omnibus::Packager::RPM
                     "rpm"
                   elsif packager == Omnibus::Packager::PKG
                     "dmg"
                   elsif packager == Omnibus::Packager::MSI || p == Omnibus::Packager::APPX
                     "msi"
                   elsif packager == Omnibus::Packager::DEB
                     "deb"
                   else
                     raise "Unexpected packager: #{p}"
                   end
    version_doc = redirect_getter.call("https://api.github.com/repos/chef/chef-workstation-tray/releases/latest", redirect_getter)
    version_info = JSON.parse(version_doc.body)
    version = version_info['name']
    download_url = nil
    version_info["assets"].each do |asset|
      if asset['browser_download_url'] =~ /.*\.#{package_type}/
        download_url = asset['browser_download_url']
        break
      end
    end

    if download_url.nil?
      raise "Trying to download tray #{version}, Could not find package type #{package_type} for packager #{p}"
    end


    FileUtils.mkdir_p target_dir
    target_path = File.join(target_dir, "chef-tray.#{package_type}")
    resp = redirect_getter.call(download_url, redirect_getter)
    File.open(target_path, "wb") { |file|  file.write(resp.body) }
    File.chmod(0755, target_path)
  end
end
