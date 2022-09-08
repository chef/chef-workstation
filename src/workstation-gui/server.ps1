Write-Output "INSIDE THE server.ps1 file"
$access_key = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})

$ws_path = "C:\opscode\chef-workstation"
$server_path = Join-Path $ws_path "embedded\service\workstation-gui" -Resolve

Set-Location -Path $ws_path
Add-Content -Path "service.txt" -Value $access_key
Write-Output "Created the service.txt file"

Set-Location -Path $server_path

if(Test-Path config\credentials.yml.enc)
{
  Remove-Item config\credentials.yml.enc
}

if(Test-Path config\master.key)
{
  Remove-Item config\master.key
}
Write-Output "Before running the rake task"
C:\opscode\chef-workstation\embedded\bin\bundle exec C:\opscode\chef-workstation\embedded\bin\rake secrets:regenerate["$access_key"]

Write-Output "After the rake task"
Set-Location -Path "config"
.\win_server.bat

Write-Output "After starting the rails server"
