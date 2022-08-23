param ($chefws_bin = (split-path $MyInvocation.MyCommand.Definition -Parent))
param ($AccessKey = (-join ((33..126) | Get-Random -Count 16 | % {[char]$_})))

# $test_path = Join-Path "C:\opscode\chef-workstation\" "testing.txt" -Resolve
$test_path = "C:\opscode\chef-workstation\test.txt"
$parent = split-path $test_path -Parent

Set-Location -Path $parent

Add-Content -Path "test.txt" -Value "This is a testing file"
