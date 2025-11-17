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

Write-Output "Verifying REXML gem version..."
$rexml_versions = & "C:/opscode/chef-workstation/embedded/bin/gem.bat" list rexml
If ($rexml_versions -match "rexml \(([\d., ]+)\)") {
    $versions = $matches[1].Split(",").Trim()
    $min_version = [System.Version]"3.4.2"
    $old_versions = $versions | Where-Object {
        $v = [System.Version]($_ -replace '^(\d+\.\d+\.\d+).*$', '$1')
        $v -lt $min_version
    }

    if ($old_versions) {
        Write-Error "Found old REXML versions: $($old_versions -join ', '). Minimum required version is 3.4.2"
        $exit = 1
    }
    Write-Output "REXML version check passed"
} else {
    Write-Error "Could not determine REXML gem version"
    $exit = 1
}
If ($lastexitcode -ne 0) { Throw $lastexitcode }
