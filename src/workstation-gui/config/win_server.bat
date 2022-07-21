@echo off
start chrome http://stackoverflow.com/questions/tagged/python+or+sql+or+sqlite+or+plsql+or+oracle+or+windows-7+or+cmd+or+excel+or+access+or+vba+or+excel-vba+or+access-vba?sort=newest
start "" c:\windows\write.exe
start "" c:\windows\notepad.exe
cd C:\Users\ngupta\Documents\chef-workstation\chef-workstation\src\workstation-gui
puma -C C:\Users\ngupta\Documents\chef-workstation\chef-workstation\src\workstation-gui\config\puma.rb