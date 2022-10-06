$access_key = -join ((48..57) + (97..122) | Get-Random -Count 16 | % {[char]$_})

$ws_path = (split-path $MyInvocation.MyCommand.Definition -Parent) | Split-Path | Split-Path | Split-Path
$bin_path = Join-Path $ws_path "embedded\bin" -Resolve
$server_path = Join-Path $ws_path "embedded\service\workstation-gui" -Resolve

Set-Location -Path $ws_path
Set-Content -Path "service.txt" -Value $access_key

Set-Location -Path $server_path

if(Test-Path config\credentials.yml.enc)
{
  Remove-Item config\credentials.yml.enc
}

if(Test-Path config\master.key)
{
  Remove-Item config\master.key
}

$regenerate_cmd = "$bin_path\bundle exec $bin_path\rake secrets:regenerate['$access_key']"
Invoke-Expression $regenerate_cmd

$puma_cmd = "$bin_path\bundle exec $bin_path\puma -C $server_path\config\puma.rb"
Invoke-Expression $puma_cmd
