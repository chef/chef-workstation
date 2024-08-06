# DO NOT MODIFY
# The chef-analyze version is pinned by Expeditor. Whenever chef-analyze
# changes are merged to main Expeditor takes that version, runs a script to
# replace it here and pushes a new commit / build through.

override "chef-analyze", version: "0.1.186"
# /DO NOT MODIFY

override "libarchive", version: "3.6.2"
override "libffi", version: "3.4.2"
override "libiconv", version: "1.16"
override "liblzma", version: "5.2.5"
override "curl", version: "8.4.0"
override "go", version: "1.21.5"
override "git-windows", version: "2.41.0"
override "libyaml", version: "0.1.7"
override "libxml2", version: "2.12.5"
override "makedepend", version: "1.0.5"
override "ncurses", version: "6.4"
override :stunnel, version: "5.71"
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "3.1.2"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "ruby-msys2-devkit", version: "3.1.2-1"
override "rust", version: "1.37.0"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.3.1"
