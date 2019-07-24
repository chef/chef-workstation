pkg_name=chef-workstation
pkg_origin=chef
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_description="Chef Workstation - Opinionated tools for getting the most out of the Chef ecosystem"
pkg_license=('Apache-2.0')
pkg_bin_dirs=(bin)
pkg_build_deps=(
  core/make
  core/gcc
  core/gcc-libs
  core/coreutils
  core/pkg-config
)


ruby_pkg="core/ruby26"
RUBY_MAJOR_MINOR_VERSION=2.6
RUBY_PATCH_VERSION=3

RUBY_VERSION=$RUBY_MAJOR_MINOR_VERSION.$RUBY_PATCH_VERSION
RUBYGEM_VERSION=$RUBY_MAJOR_MINOR_VERSION.0

pkg_deps=(
  core/glibc
  core/busybox-static
  ${ruby_pkg}
  core/libxml2
  core/libxslt
  core/xz
  core/zlib
  core/bundler
  core/openssl
  core/cacerts
  core/libffi
  core/libarchive
  core/git
)

pkg_svc_user=root

pkg_version() {
  cat /src/VERSION
}

do_before() {
  do_default_before
  update_pkg_version
}

do_verify() {
  return 0
}



do_prepare() {
  export OPENSSL_LIB_DIR=$(pkg_path_for openssl)/lib
  export OPENSSL_INCLUDE_DIR=$(pkg_path_for openssl)/include
  export SSL_CERT_FILE=$(pkg_path_for cacerts)/ssl/cert.pem

  build_line "Setting link for /usr/bin/env to 'coreutils'"
  [[ ! -f /usr/bin/env ]] && ln -s $(pkg_path_for coreutils)/bin/env /usr/bin/env

  return 0
}

vendor_path=abspath "$CACHE_PATH/vendor"
do_build() {
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"

  local _bundler_dir=$(pkg_path_for bundler)
  local _libxml2_dir=$(pkg_path_for libxml2)
  local _libxslt_dir=$(pkg_path_for libxslt)
  local _zlib_dir=$(pkg_path_for zlib)

  # TODO this appears to give us no depsolver? What are the effects?
  export GEM_HOME=${pkg_prefix}
  export GEM_PATH=${_bundler_dir}:${GEM_HOME}

  nokogiri_config="--use-system-libraries --with-zlib-dir=${_zlib_dir} --with-xslt-dir=${_libxslt_dir} --with-xml2-dir=${_libxml2_dir} --with-xml2-include=${_libxml2_dir}/include/libxml2 --with-xml2-lib=${_libxml2_dir}/lib --without-iconv"

  pushd "components/gems"
    bundle config --local build.nokogiri "${nokogiri_config}"
    bundle config --local silence_root_warning 1

    bundle install --without dep_selector --no-deployment --jobs 10 --retry 5 --path $pkg_prefix

  popd

}

#######################################################
# !!!              IMPORTANT REMINDER             !!! #
#######################################################
# Any changes to plan.sh related to installed gems    #
# (eg 'without' flags, additions/removals) must       #
# also be updated in omnibus/config/software/gems.rb  #
#######################################################

do_install() {
  mkdir -p $pkg_prefix/ruby-bin
  pushd "components/gems"

    appbundle "chef-cli"  "changelog,docs,debug"
    wrap_ruby_bin "chef"

    appbundle "chef-bin" "docgen,chefstyle"
    wrap_ruby_bin "chef-client"
    wrap_ruby_bin "chef-solo"
    wrap_ruby_bin "chef-resource-inspector"
    wrap_ruby_bin "chef-shell"
    wrap_ruby_bin "knife"

    appbundle "inspec-bin" "changelog,debug,docs,development"
    wrap_ruby_bin "inspec"

    appbundle ohai "changelog"
    wrap_ruby_bin "ohai"

    appbundle "foodcritic" "development,test"
    wrap_ruby_bin "foodcritic"

    appbundle "test-kitchen" "changelog,debug,docs,development"
    wrap_ruby_bin "kitchen"

    appbundle "berkshelf" "changelog,debug,docs,development"
    wrap_ruby_bin "berks"

    appbundle cookstyle "changelog"
    wrap_ruby_bin "cookstyle"

    appbundle "chef-vault" "changelog"
    wrap_ruby_bin "chef-vault"

    appbundle "opscode-pushy-client" "changelog"
    wrap_ruby_bin "pushy-client"
    wrap_ruby_bin "push-apply"
    wrap_ruby_bin "pushy-service-manager"

    appbundle chef-apply "changelog,docs,debug" # really, chef-run
    wrap_ruby_bin "chef-run"

    if [[ `readlink /usr/bin/env` = "$(pkg_path_for coreutils)/bin/env" ]]; then
      build_line "Removing the symlink we created for '/usr/bin/env'"
      rm /usr/bin/env
    fi

    mkdir -p $pkg_prefix/bin

  popd

}

appbundle() {
  bundle exec appbundler . $pkg_prefix/ruby-bin $1 --without $2
}

do_clean() {
  do_default_clean
  # Don't leave this behind - our bundle options will create this
  # owned by root, making it an annoying cleanup if you're also
  # doing a 'bundle install' outside of hab.
  rm -rf "components/gems/.bundle"
}

# Stubs
do_strip() {
  return 0
}

# Copied from https://github.com/habitat-sh/core-plans/blob/f84832de42b300a64f1b38c54d659c4f6d303c95/bundler/plan.sh#L32
wrap_ruby_bin() {
  local bin_basename="$1"
  local real_cmd="$pkg_prefix/ruby-bin/$bin_basename"
  local wrapper="$pkg_prefix/bin/$bin_basename"

  build_line "Adding wrapper $wrapper for $real_cmd"
  cat <<EOF > "$wrapper"
#!$(pkg_path_for busybox-static)/bin/sh
set -e
if test -n "$DEBUG"; then set -x; fi
export VIA_HABITAT="true"
export HAB_WS_BIN_DIR="$pkg_prefix/bin"
export HAB_WS_EMBEDDED_DIR="$pkg_prefix/ruby-bin:$(hab pkg path core/bundler):$(hab pkg path $ruby_pkg)/bin"
export GEM_HOME="$pkg_prefix/ruby/$RUBYGEM_VERSION"
export GEM_PATH="$(pkg_path_for $ruby_pkg)/lib/ruby/gems/$RUBYGEM_VERSION:$(pkg_path_for core/bundler):$pkg_prefix/ruby/$RUBYGEM_VERSION:$GEM_HOME"
export SSL_CERT_FILE=$(pkg_path_for core/cacerts)/ssl/cert.pem
# Tell the appbundler bin not to reset GEM_HOME and GEM_PATH. Has nothing to do with RVM.
export APPBUNDLER_ALLOW_RVM=true
unset RUBYOPT GEMRC
exec $(pkg_path_for $ruby_pkg)/bin/ruby ${real_cmd} \$@
EOF
  chmod -v 755 "$wrapper"
}
