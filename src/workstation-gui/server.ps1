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
Write-Output "Cleaned the existing credentials"

# Killing the process that utilises port 7050 during an update can be used to restart the service.
Write-Output "Trying to kill the existing service"
$serverProcess = netstat -ano | findstr "PID :7050"
$activePortPattern = ":7050\s.+LISTENING\s+\d+$"
$pidNumberPattern = "\d+$"

IF ($serverProcess | Select-String -Pattern $activePortPattern -Quiet) {
  $matches = $serverProcess | Select-String -Pattern $activePortPattern
  $firstMatch = $matches.Matches.Get(0).Value

  $pidNumber = [regex]::match($firstMatch, $pidNumberPattern).Value
  taskkill /pid $pidNumber /f
  Write-Output "Terminated the service after locating it running on PID:$pidNumber."
}

Start-Process -WindowStyle Hidden -File "$bin_path\bundle" -ArgumentList "exec", "$bin_path\rake", "secrets:regenerate['$access_key']"
Write-Output("Regenerated the secrets")

Start-Process -WindowStyle Hidden -File "$bin_path\bundle" -ArgumentList "exec", "$bin_path\puma", "-C", "$server_path\config\puma.rb"
Write-Output("Start the service on port 7050.")
