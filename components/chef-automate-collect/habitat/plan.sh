pkg_name=chef-automate-collect
pkg_origin=chef
pkg_description="Chef Policy Rollout Client CLI"
pkg_maintainer="Chef Software Inc. <support@chef.io>"
pkg_bin_dirs=(bin)
pkg_deps=(core/glibc)
pkg_scaffolding=core/scaffolding-go
scaffolding_go_module=on

pkg_version() {
  cat "$SRC_PATH/VERSION"
}

do_before() {
  do_default_before
  update_pkg_version
}

do_prepare() {
  build_line "Setting GOFLAGS=\"-mod=vendor\""
  export GOFLAGS="-mod=vendor"

  build_line "Running all 'go generate' statements before building"
  ( cd "$SRC_PATH" || exit_with "unable to cd into source directory" 1
    go generate ./...
  )
}
