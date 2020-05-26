# DO NOT MODIFY
# The delivery-cli, chef-analyze and workstation app versions are pinned by Expeditor.
# Whenever chef-analyze, workstation-app and delivery cli are merged to master then
# Expeditor takes that version, runs a script to replace it here and pushes a new
# commit / build through.

override "chef-analyze", version: "0.1.91"
override "delivery-cli", version: "0.0.54"
override "chef-workstation-app", version: "v0.1.79"
# /DO NOT MODIFY

override "libarchive", version: "3.4.2"
override "libffi", version: "3.2.1"
override "libiconv", version: "1.15"
override "liblzma", version: "5.2.4"
override "libxml2", version: "2.9.10"
override "libxslt", version: "1.1.34"
override "libyaml", version: "0.1.7"
override "libzmq", version: "4.0.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "5.9"
override "openssl", version: "1.0.2v"
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "2.7.1"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "rust", version: "1.37.0"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"
