# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

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

# chef-run version ensures our bin ends up on path and the basic ruby env is working.
chef-run --version
If ($lastexitcode -ne 0) { Exit $lastexitcode }

# Ensure our Chef Workstation works
chef env
If ($lastexitcode -ne 0) { Exit $lastexitcode }

# Run Chef Workstation verification suite to ensure it still works
chef verify
If ($lastexitcode -ne 0) { Exit $lastexitcode }
