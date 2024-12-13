$pkg_name="openssl"
$pkg_origin="core"
$pkg_version="3.0.12"
$pkg_description="OpenSSL is an open source project that provides a robust, commercial-grade, and full-featured toolkit for the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols. It is also a general-purpose cryptography library."
$pkg_upstream_url="https://www.openssl.org"
$pkg_license=@("OpenSSL")
$pkg_source="https://www.openssl.org/source/${pkg_name}-${pkg_version}.tar.gz"
$pkg_source="https://github.com/openssl/openssl/archive/refs/tags/openssl-$pkg_version.zip"
$pkg_shasum="d949fd0a1ae8578fb055db9110cf074a9ca76b01105a8144f0e7035860023694"
$pkg_build_deps=@("core/visual-cpp-build-tools-2015", "core/perl", "core/nasm")
$pkg_bin_dirs=@("bin")
$pkg_include_dirs=@("include")
$pkg_lib_dirs=@("lib")

function Invoke-Build {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    perl Configure VC-WIN64A --prefix=$pkg_prefix --openssldir=$pkg_prefix\SSL no-unit-test no-comp no-idea no-mdc2 no-rc5 no-ssl3 no-zlib shared enable-fips enable-legacy

    nmake
    if($LASTEXITCODE -ne 0) { Write-Error "nmake failed!" }
    nmake install_fips
}

function Invoke-Install {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    nmake install
}

function Invoke-Check {
    Set-Location "$pkg_name-$pkg_name-$pkg_version"
    nmake test
}

function Invoke-End {
  Write-Host "Enabling FIPS and legacy providers"
  Copy-Item "$PLAN_CONTEXT/openssl.cnf" "$pkg_prefix/SSL/openssl.cnf"
  $filepath = "${pkg_prefix}/SSL/openssl.cnf"
  $content = Get-Content $filepath
  $new_path = $pkg_prefix.Replace("\", "/")
  $content = $content -replace ".include fipsmodule.cnf", ".include ${new_path}/SSL/fipsmodule.cnf"
  Set-Content $filepath -Value $content
}