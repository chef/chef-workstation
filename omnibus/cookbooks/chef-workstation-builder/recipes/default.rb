# ensure packages available up-to-date
case node["platform_family"]
when "debian"
  include_recipe "apt::default"
when "rhel"
  include_recipe "yum-epel::default"
end

include_recipe "omnibus::default"

execute "fix bundler directory permissions" do
  command "chown -R #{node["omnibus"]["build_user"]} #{node["omnibus"]["build_user_home"]}/.bundle"
  only_if { Dir.exist? "#{node["omnibus"]["build_user_home"]}/.bundle" }
end

omnibus_build "chef-workstation" do
  environment "HOME" => node["omnibus"]["build_user_home"]
  project_dir node["omnibus"]["build_dir"]
  log_level node["chef-workstation-builder"]["log_level"].to_sym
  live_stream node["chef-workstation-builder"]["live_stream"]
  config_overrides(
    append_timestamp: true
  )
end
