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
  Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "server"
}
