program="openssl"

pkg_name="openssl"
pkg_origin="core"
pkg_version="3.0.12"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
OpenSSL is an open source project that provides a robust, commercial-grade, \
and full-featured toolkit for the Transport Layer Security (TLS) and Secure \
Sockets Layer (SSL) protocols. It is also a general-purpose cryptography \
library.\
"
pkg_upstream_url="https://www.openssl.org"
pkg_license=('Apache-2.0')
pkg_source="https://www.openssl.org/source/${program}-${pkg_version}.tar.gz"
pkg_shasum="f93c9e8edde5e9166119de31755fc87b4aa34863662f67ddfcba14d0b6b69b61"
pkg_dirname="${program}-${pkg_version}"
pkg_deps=(
    core/glibc
)
pkg_build_deps=(
    core/coreutils
    core/gcc
    core/grep
    core/make
    core/sed
    core/perl
    core/patch
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
case $pkg_target in
        aarch64-linux)
                pkg_lib_dirs=(lib)
                pkg_pconfig_dirs=(lib/pkgconfig)
                ;;
        x86_64-linux)
                pkg_lib_dirs=(lib64)
                pkg_pconfig_dirs=(lib64/pkgconfig)
                ;;
        esac

do_prepare() {
    patch -p1 <"$PLAN_CONTEXT/ca_fips_legacy.patch"

    export CROSS_SSL_ARCH="${native_target}"
    # Set PERL var for scripts in `do_check` that use Perl
    PERL=$(pkg_path_for core/perl)/bin/perl
    export PERL
    build_line "Setting PERL=${PERL}"
}

do_build() {
  "$(pkg_path_for core/perl)/bin/perl" ./Configure \
        --prefix="${pkg_prefix}" \
        --openssldir=ssl \
        no-unit-test \
        no-comp \
        no-idea \
        no-mdc2 \
        no-rc5 \
        no-ssl2 \
        no-ssl3 \
        no-zlib \
        shared \
        enable-fips \
        enable-legacy

    make -j"$(nproc)"

    # For FIPS module
    make "install_fips"
}

do_check() {
    make test
}

do_install() {
    do_default_install
    cp $CACHE_PATH/LICENSE.txt "$pkg_prefix"
    # Remove dependency on Perl at runtime
    rm -rfv "$pkg_prefix/ssl/misc" "$pkg_prefix/bin/c_rehash"

}

do_after_success() {
  # Activate the fips module
  build_line "Activating the FIPS module"
  echo "_____________________________________"
  cat ${pkg_prefix}/ssl/openssl.cnf
  echo "_____________________________________"
  sed -i -e "s|.include fipsmodule.cnf|.include ${pkg_prefix}/ssl/fipsmodule.cnf|g" ${pkg_prefix}/ssl/openssl.cnf
}
