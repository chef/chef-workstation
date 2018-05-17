#
# Cookbook:: deploy_website
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

service "nginx" do
  action :nothing
end

link "/etc/nginx/sites-enabled/default" do
  action :delete
end

remote_directory "/var/www/demosite" do
  source "demosite"
  mode "0755"
  recursive true
  action :create
end

template "/etc/nginx/sites-available/demosite" do
  source "demosite.erb"
end

link "/etc/nginx/sites-enabled/demosite" do
  to "/etc/nginx/sites-available/demosite"
  notifies :restart, "service[nginx]"
end
