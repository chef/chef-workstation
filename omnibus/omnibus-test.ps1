# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

# reload Env:PATH to ensure it gets any changes that the install made (e.g. C:\opscode\chef-workstation\bin\ )
$Env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Ensure user variables are set in git config
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

$Env:CHEF_LICENSE = "accept-no-persist"
$Env:HAB_LICENSE = "accept-no-persist"

Write-Output "--- Verifying commands"
Write-Output " * chef env"
chef env
If ($lastexitcode -ne 0) { Throw $lastexitcode }

Write-Output " * chef report"
chef report help
If ($lastexitcode -ne 0) { Throw $lastexitcode }

Write-Output " * hab help"
hab help
If ($lastexitcode -ne 0) { Throw $lastexitcode }

# We are commenting this code on a purpose.
# We have to stop building chef-automate-collect in chef workstation temporarily.
# Please refer the issue: https://github.com/chef/chef-workstation/issues/2286

# Write-Output " * chef-automate-collect -h"
# chef exec chef-automate-collect -h
# If ($lastexitcode -ne 0) { Throw $lastexitcode }

Write-Output "--- Run the verification suite"
C:/opscode/chef-workstation/embedded/bin/ruby.exe omnibus/verification/run.rb
If ($lastexitcode -ne 0) { Throw $lastexitcode }
