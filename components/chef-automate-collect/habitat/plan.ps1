$pkg_name="chef-automate-collect"
$pkg_origin="chef"
$pkg_description="Chef Policy Rollout Client CLI"
$pkg_maintainer="Chef Software Inc. <support@chef.io>"
$pkg_bin_dirs=@("bin")
$pkg_build_deps=@("core/go")

function pkg_version {
  Get-Content "$SRC_PATH/VERSION"
}

function Invoke-Before {
  Set-PkgVersion
}

function Invoke-Prepare {
  $Env:GOFLAGS = "-mod=vendor"
  Write-BuildLine "Setting GOFLAGS=$env:GOFLAGS"
}

function Invoke-Install {
  Push-Location "$SRC_PATH"
  go build -o $pkg_prefix/bin/chef-automate-collect.exe
}

function Invoke-Check{
  $Env:CHEF_FEAT_ANALYZE = "true"
  (& "$pkg_prefix/bin/chef-automate-collect.exe" version).StartsWith("Collect data for Chef Automate")
}
