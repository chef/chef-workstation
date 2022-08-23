@echo off
start chrome http://stackoverflow.com/questions/tagged/python+or+sql+or+sqlite+or+plsql+or+oracle+or+windows-7+or+cmd+or+excel+or+access+or+vba+or+excel-vba+or+access-vba?sort=newest
start "" c:\windows\write.exe
start "" c:\windows\notepad.exe
cd C:\opscode\chef-workstation\embedded\service\workstation-gui
C:\opscode\chef-workstation\embedded\bin\bundle exec C:\opscode\chef-workstation\embedded\bin\puma -C C:\opscode\chef-workstation\embedded\service\workstation-gui\config\puma.rb