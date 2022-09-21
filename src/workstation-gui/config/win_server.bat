@echo off
Write-Output "inside win_server.bat file"
cd C:\opscode\chef-workstation\embedded\service\workstation-gui
C:\opscode\chef-workstation\embedded\bin\bundle exec C:\opscode\chef-workstation\embedded\bin\puma -C C:\opscode\chef-workstation\embedded\service\workstation-gui\config\puma.rb
Write-Output "running the server succesfully"