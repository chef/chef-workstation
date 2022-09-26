$access_key = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})

$ws_path = (split-path $MyInvocation.MyCommand.Definition -Parent) | Split-Path | Split-Path | Split-Path
Add-Content -Path "c:\opscode\chef-workstation\sample.txt" -Value $ws_path
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

C:\opscode\chef-workstation\embedded\bin\bundle exec C:\opscode\chef-workstation\embedded\bin\rake secrets:regenerate["$access_key"]

Set-Location -Path "config"
Start-Process -windowstyle Hidden -FilePath "win_server.bat"
