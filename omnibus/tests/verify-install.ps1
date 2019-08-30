# Stop script execution when a non-terminating error occurs
# TODO do we still have tod do the exit code checks with this set? 
# TODO - this is global to all cmdlets? Can this change something in the user's 
#        default powershell config? 
$ErrorActionPreference = "Stop"

function CreateTempDir
{
   $tmpDir = [System.IO.Path]::GetTempPath()
   $tmpDir = [System.IO.Path]::Combine($tmpDir, [System.IO.Path]::GetRandomFileName())
  
   [System.IO.Directory]::CreateDirectory($tmpDir) | Out-Null

   $tmpDir
}

function SwitchToTempDir
{
    $dir = CreateTempDir
    Push-Location $dir
}

function LeaveAndCleanTempDir
{
    $temp_dir = $pwd.Path
    Pop-Location 
    Remove-Item  $temp_dir -Force

}

function GetGemDir($gem)
{
    $gem_which = gem which $name
    (Get-Item $gem_which).parent
}

$channel = "$Env:CHANNEL"
If ([string]::IsNullOrEmpty($channel)) { $channel = "unstable" }

$product = "$Env:PRODUCT"
If ([string]::IsNullOrEmpty($product)) { $product = "chef-workstation" }

$version = "$Env:VERSION"
If ([string]::IsNullOrEmpty($version)) { $version = "latest" }

Write-Output "--- Installing $channel $product $version"
$package_file = $(C:\opscode\omnibus-toolchain\bin\install-omnibus-product.ps1 -Product "$product" -Channel "$channel" -Version "$version" | Select-Object -Last 1)

Write-Output "--- Verifying omnibus package is signed"
C:\opscode\omnibus-toolchain\bin\check-omnibus-package-signed.ps1 "$package_file"

Write-Output "--- Running verification for $channel $product $version"

# reload Env:PATH to ensure it gets any changes that the install made (e.g. C:\opscode\chef-workstation\bin\ )
$Env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Ensure user variables are set in git config
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

$Env:CHEF_LICENSE = "accept-no-persist"

# Ensure `chef` works 
chef env
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Verifying package installation"

Write-Output "    --> berks"
berks -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> Chef CLI"
chef -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> chef-client"
chef-client -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> chef-solo"
chef-solo -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> delivery [skipping - windows]"
# delivery -V
# If ($lastexitcode -ne 0) { Exit $lastexitcode }

# In `knife`, `knife -v` follows a different code path that skips
# command/plugin loading; `knife -h` loads commands and plugins, but
# it exits with code 1, which is the same as a load error. Running
# `knife exec` forces command loading to happen and this command
# exits 0, which runs most of the code.
#
# See also: https://github.com/chef/chef-dk/issues/227
knife exec -E true
If ($lastexitcode -ne 0) { Exit $lastexitcode }


Write-Output "    --> kitchen"
# kitchen makes a .kitchen, so do it in a temp place
SwitchToTempDir
kitchen -v
If ($lastexitcode -ne 0) { Exit $lastexitcode }
LeaveAndCleanTempDir


Write-Output "    --> ohai"
ohai -v 
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> foodcritic"
foodcritic -V 
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> inspec"
inspec version
If ($lastexitcode -ne 0) { Exit $lastexitcode }


Write-Output " -- Verifying Test Kitchen"
Push-Location GetGemDir("kitchen")
bundle install --quiet --with=development
Write-Output "    --> unit tests"
bundle exec rake unit
Write-Output "    --> integration tests"
bundle exec rake features
Pop-Location 
Write-Output "    --> smoke test"
SwitchToTempDir
kitchen init --create-gemfile
If ($lastexitcode -ne 0) { Exit $lastexitcode }
LeaveAndCleanTempDir

Write-Output " -- Verifying policyfile provisioning"
SwitchToTempDir
# TODO - let's put all of our content into files so that we don't have
#        that we can copy in, so that we don't have to do this for both platforms 
Set-Content -Path 'kitchen.yml' -Value @'
---
driver:
  name: dummy
  network:
    - ["forwarded_port", {guest: 80, host: 8080}]

provisioner:
  name: policyfile_zero
  require_chef_omnibus: 12.3.0

platforms:
  - name: ubuntu-14.04

suites:
  - name: default
    run_list:
      - recipe[aar::default]
    attributes:

'@
kitchen list
If ($lastexitcode -ne 0) { Exit $lastexitcode }
LeaveAndCleanTempDir

Write-Output " -- Verifying Chef Infra"
Push-Location GetGemDir("chef")
bundle install --quiet
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> unit tests"
bundle exec rspec -fp -t "~volatile_from_verify" "spec/unit"
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> integration tests"
bundle exec rspec -fp "spec/integration" "spec/functional"
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> smoke tests"
SwitchToTempDir
New-Item -Path "apply.rb" -ItemType File
chef-apply apply.rb
If ($lastexitcode -ne 0) { Exit $lastexitcode }
LeaveAndCleanTempDir

Pop-Location


Write-Output " -- Verifying Chef CLI"
Push-Location GetGemDir("chef-cli")
bundle install --quiet
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> unit tests"
bundle exec rspec 
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "    --> smoke tests"
SwitchToTempDir
chef generate cookbook example
If ($lastexitcode -ne 0) { Exit $lastexitcode }
Write-Output "    --> verifying tests pass for generated cookbook"
Push-Location "example"
rspec
If ($lastexitcode -ne 0) { Exit $lastexitcode }
Pop-Location

Pop-Location # gem home

