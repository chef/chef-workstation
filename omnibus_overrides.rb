# DO NOT MODIFY
# The chef-analyze version is pinned by Expeditor. Whenever chef-analyze
# changes are merged to main Expeditor takes that version, runs a script to
# replace it here and pushes a new commit / build through.

override "chef-analyze", version: "0.1.142"
# /DO NOT MODIFY

override "libarchive", version: "3.5.2"
override "libffi", version: "3.3"
override "libiconv", version: "1.16"
override "liblzma", version: "5.2.5"
override "libxml2", version: "2.9.10"
override "libxslt", version: "1.1.34"
override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "5.9"
override "openssl", version: macos? ? "1.1.1m" : "1.0.2zb"
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "3.0.3"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "rust", version: "1.37.0"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"
