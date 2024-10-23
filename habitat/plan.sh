pkg_name=chef-workstation
pkg_origin=chef
pkg_maintainer="The Chef Maintainers <humans@chef.io>"
pkg_description="Chef Workstation - Opinionated tools for getting the most out of the Chef ecosystem"
pkg_license=('Apache-2.0')
pkg_bin_dirs=(bin)
pkg_svc_user=root
ruby_pkg="core/ruby31"
pkg_build_deps=(
  core/make
  core/gcc
  core/go22
  core/gcc-libs
  core/pkg-config
  "${pkg_origin}/chef-analyze"
)
pkg_deps=(
  core/glibc
  core/bash
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
  core/coreutils
  core/git
  "${pkg_origin}/cookstyle"
  "${pkg_origin}/berkshelf"
  "${pkg_origin}/chef-cli"
)

pkg_version() {
  cat "${SRC_PATH}/VERSION"
}

do_before() {
  do_default_before
  update_pkg_version
}

do_verify() {
  return 0
}

do_prepare() {
  # Clear any existing GEM_PATH
  unset GEM_PATH

  # Set GEM_HOME and GEM_PATH
  export GEM_HOME="$pkg_prefix/vendor"
  export GEM_PATH="$GEM_HOME"  # Initialize GEM_PATH to only GEM_HOME
  export PATH="$GEM_HOME/bin:$PATH"  # Add GEM_HOME/bin to PATH
  export OPENSSL_LIB_DIR=$(pkg_path_for openssl)/lib
  export OPENSSL_INCLUDE_DIR=$(pkg_path_for openssl)/include
  export SSL_CERT_FILE=$(pkg_path_for cacerts)/ssl/cert.pem
  export RUBY_ABI_VERSION=$(ls $(pkg_path_for ${ruby_pkg})/lib/ruby/gems)
  export GOPROXY=https://proxy.golang.org,direct
  build_line "Using Ruby ABI version '${RUBY_ABI_VERSION}'"

  build_line "Setting link for /usr/bin/env to 'coreutils'"
  if [ ! -f /usr/bin/env ]; then
    ln -s "$(pkg_interpreter_for core/coreutils bin/env)" /usr/bin/env
  fi

# Set the path for ruby from the core/ruby31 package
RUBY_PATH="$(hab pkg path core/ruby31)/bin/ruby"

# Check if the ruby executable exists
if [ -x "$RUBY_PATH" ]; then
    # Create the symlink for ruby
    ln -sf "$RUBY_PATH" /usr/bin/env
    echo "Symlink created: /usr/bin/ruby -> $RUBY_PATH"
else
    echo "Error: Ruby executable not found at $RUBY_PATH"
fi
}

do_build() {
  # Set up environment variables for the build
  export GEM_HOME="$pkg_prefix"
  export GEM_PATH="${GEM_HOME}"
  export PATH="$PATH:/hab/pkgs/core/ruby31/3.1.6/20240912144513/bin"

  # sed -i '1s|^.*|#!/hab/pkgs/core/ruby31/3.1.6/20240912144513/bin/ruby|' /hab/pkgs/ngupta26/cookstyle/7.32.11/20241006190955/vendor/bin/rspec


  export NOKOGIRI_CONFIG
  NOKOGIRI_CONFIG="--use-system-libraries \
    --with-zlib-dir=$(pkg_path_for zlib) \
    --with-xslt-dir=$(pkg_path_for libxslt) \
    --with-xml2-include=$(pkg_path_for libxml2)/include/libxml2 \
    --with-xml2-lib=$(pkg_path_for libxml2)/lib \
    --without-iconv"

  ( cd "${SRC_PATH}/components/gems" || exit_with "unable to enter components/gems directory" 1
    bundle config --local build.nokogiri "$NOKOGIRI_CONFIG"
    bundle config --local silence_root_warning 1
    bundle config set --local without dep_selector
    bundle config set --local without all 

    # Install the gems listed in the Gemfile
    
    # bundle install --jobs 10 --retry 5 --path "$pkg_prefix"

    ruby "${SRC_PATH}/components/gems/post-bundle-install.rb"
  )

  build_line "Building top-level 'chef' CMD wrapper"
  ( cd "${SRC_PATH}/components/main-chef-wrapper" || exit_with "unable to enter main-chef-wrapper directory" 1
    CGO_ENABLED=0 go build -o "$pkg_prefix/bin/chef"
  )

  build_line "Creating gem-version-manifest........"
  ruby "${SRC_PATH}/config/software/installed_gems_as_json.rb"
}


do_install() {
  export GEM_HOME="$pkg_prefix"
  export GEM_PATH="${GEM_HOME}"

  build_line "Installing binaries from Habitat packages"

  if [ "$(readlink /usr/bin/env)" = "$(pkg_interpreter_for core/coreutils bin/env)" ]; then
    build_line "Removing the symlink created for '/usr/bin/env'"
    rm /usr/bin/env
  fi
}

appbundle() {
  build_line "AppBundling gem: '$1' without: '$2'"
  bundle exec appbundler . "$ruby_bin_dir" "$1" --without "$2" >/dev/null
}

do_end() {
  do_default_end
  rm -rf "${SRC_PATH}/components/gems/.bundle"
}

do_strip() {
  return 0
}

wrap_ruby_bin() {
  local bin_basename="$1"
  local real_cmd="$ruby_bin_dir/$bin_basename"
  local wrapper="$pkg_prefix/bin/$bin_basename"

  build_line "Adding wrapper for '$bin_basename': $wrapper -> $real_cmd"
  cat <<EOF > "$wrapper"
#!$(pkg_interpreter_for core/bash bin/sh)
set -e
if test -n "\$DEBUG"; then set -x; fi
export HAB_WS_PATH="$pkg_prefix"
export HAB_WS_EMBEDDED_DIR="${ruby_bin_dir}:$(hab pkg path core/bundler):$(hab pkg path $ruby_pkg)/bin"

export GEM_HOME="$pkg_prefix/ruby/$RUBY_ABI_VERSION"
export GEM_PATH="$(pkg_path_for $ruby_pkg)/lib/ruby/gems/${RUBY_ABI_VERSION}:$(pkg_path_for core/bundler):${pkg_prefix}/ruby/${RUBY_ABI_VERSION}:${pkg_prefix}"
export SSL_CERT_FILE=$(pkg_path_for core/cacerts)/ssl/cert.pem

export APPBUNDLER_ALLOW_RVM=true
unset RUBYOPT GEMRC
exec $(pkg_path_for $ruby_pkg)/bin/ruby ${real_cmd} "\$@"
EOF
  chmod -v 755 "$wrapper"
}
