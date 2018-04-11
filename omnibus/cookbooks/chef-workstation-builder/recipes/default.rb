include_recipe 'omnibus::default'

execute 'fix bundler directory permissions' do
  command "chown -R #{node['omnibus']['build_user']} #{node['omnibus']['build_user_home']}/.bundle"
end

omnibus_build 'chef-workstation' do
  environment 'HOME' => node['omnibus']['build_user_home']
  project_dir node['omnibus']['build_dir']
  log_level :internal
  live_stream true
  config_overrides(
    append_timestamp: true
  )
end
