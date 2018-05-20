#
# Cookbook:: deploy_website
# Recipe:: default
#

# yum_repository 'zenoss' do
#   description "Zenoss Stable repo"
#   baseurl "http://dev.zenoss.com/yum/stable/"
#   gpgkey 'http://dev.zenoss.com/yum/RPM-GPG-KEY-zenoss'
#   action :create
# end

template "/etc/yum.repos.d/nginx.repo" do
  source "yum_repo.erb"
end

package "nginx"

file "/etc/nginx/conf.d/default.conf" do
  action :delete
end

remote_directory "/var/www/demosite" do
  source "demosite"
  mode "0755"
  recursive true
  action :create
end

# %w(sites-available sites-enabled).each do |dir|
#   directory "/etc/nginx/#{dir}" do
#     action :create
#   end
# end

template "/etc/nginx/conf.d/demosite.conf" do
  source "demosite.erb"
  notifies :restart, "service[nginx]"
end

# link "/etc/nginx/sites-enabled/demosite" do
#   to "/etc/nginx/sites-available/demosite"
#   notifies :restart, "service[nginx]"
# end

service "nginx" do
  action [:start, :enable]
end
