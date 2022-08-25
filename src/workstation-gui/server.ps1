$access_key = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})

$ws_path = "C:\opscode\chef-workstation"
$server_path = Join-Path $ws_path "embedded\service\workstation-gui" -Resolve

Set-Location -Path $ws_path
Add-Content -Path "service.txt" -Value $access_key

Set-Location -Path $server_path

if(Test-Path config\credentials.yml.enc)
{
  Remove-Item config\credentials.yml.enc
}

if(Test-Path config\master.key)
{
  Remove-Item config\master.key
}

bundle exec rake secrets:regenerate["$access_key"]

Set-Location -Path "config"
.\win_server.bat