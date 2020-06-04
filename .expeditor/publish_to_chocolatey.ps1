$ErrorActionPreference="stop"

$version = "$Env:EXPEDITOR_VERSION"
$secondsDelay = 20 # seconds
$retries = 60 # retry for up to 20 minutes
$completed = $false
$retrycount = 0
$output = "./cw"

Write-Host "--- Fetching version $version data from omnitruck API"
$metadataUri = "https://omnitruck.chef.io/stable/chef-workstation/metadata?p=windows&pv=2016&m=x86_64&v=$version"
while (-not $completed) {
    try {
        $releaseRecord = Invoke-RestMethod -Uri $metadataUri -Headers @{accept="application/json"} -ErrorAction Stop
        $completed = $?
    } catch {
        if ($retrycount -ge $retries) {
            throw "Fetching version $version failed the maximum number of $retrycount times."
        } else {
            Write-Host "Fetching version $version failed. Retrying in $secondsDelay seconds."
            Start-Sleep $secondsDelay
            $retrycount++
        }
    }
}
Write-Host "Successfully fetched version $version information"

# We want to ensure we can fetch the metadata AND download the file successfully
$completed = $false
$retrycount = 0
$output = "./cw"
Write-Host "--- Fetching package from omnitruck API"
while (-not $completed) {
    try {
        (New-Object System.Net.WebClient).DownloadFile($releaseRecord.url, $output)
        $completed = $?
    } catch {
        if ($retrycount -ge $retries) {
            throw "Fetching package failed the maximum number of $retrycount times."
        } else {
            Write-Host "Fetching package failed. Retrying in $secondsDelay seconds."
            Start-Sleep $secondsDelay
            $retrycount++
        }
    }
}
Write-Host ("Successfully downloaded Chef Workstation from {0}" -f $releaseRecord.url)

Write-Host "--- Copying templates locally"
$tempDir = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
New-Item $tempDir -ItemType Directory -Force | Out-Null
Copy-Item -Path "components/packaging/chocolatey/*" -Destination $tempDir -Recurse

Write-Host "--- Patching templates"
$files = Get-ChildItem  -Path $tempDir -Filter *.*  -Recurse | Where-Object {!$_.PSIsContainer} | Select-Object FullName
ForEach ($file in $files) {
    (Get-Content $file.FullName).
        Replace('$url$', $releaseRecord.url).
        Replace('$version$', $releaseRecord.version).
        Replace('$checksum$', $releaseRecord.sha256) |
        Set-Content $file.FullName

    Write-Host "--- DEBUG - Patched " $file.FullName " follows:"
    Get-Content $file.FullName | Write-Host
}

Write-Host "--- Publishing package"

$valid_build_creator="Chef Expeditor"
$pack_cmd = "choco pack $tempDir/chef-workstation.nuspec --version " + $releaseRecord.version
$publish_cmd = "choco push chef-workstation." + $releaseRecord.version + ".nupkg --timeout 600"

try {
    if($env:BUILDKITE_BUILD_CREATOR -eq $valid_build_creator) {
        Invoke-Expression $pack_cmd
        if ($LASTEXITCODE -ne 0) { throw "unable to choco pack" }
        Invoke-Expression "$publish_cmd --key $env:CHOCO_API_KEY"
        if ($LASTEXITCODE -ne 0) { throw "unable to publish Chocolatey package" }
    } else {
        Write-Host "--- NOT PUBLISHING: Build triggered by $env:BUILDKITE_BUILD_CREATOR and not $valid_build_creator"
        Write-Host $pack_cmd
        Write-Host $publish_cmd " --key <elided ChocoApiKey>"
    }
} finally {
    Remove-Item $tempDir -Recurse -Force
}
