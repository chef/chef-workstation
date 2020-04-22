$packageArgs = @{
    packageName    = 'chef-workstation'
    unzipLocation  = $toolsDir
    fileType       = 'MSI'
    # These are replaced in in publish_to_chocolatey.ps1
    url64bit       = '$url$'
    checksum64     = '$checksum$'
    checksumType64 = 'sha256'
    silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
    validExitCodes = @(0, 3010)
}

Install-ChocolateyPackage @packageArgs
