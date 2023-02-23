# DO NOT MODIFY
# The chef-analyze version is pinned by Expeditor. Whenever chef-analyze
# changes are merged to main Expeditor takes that version, runs a script to
# replace it here and pushes a new commit / build through.

override "chef-analyze", version: "0.1.185"
# /DO NOT MODIFY

override "libarchive", version: "3.5.2"
override "libffi", version: "3.4.2"
override "libiconv", version: "1.16"
override "liblzma", version: "5.2.5"

# libxslt 1.1.35 does not build successfully with libxml2 2.9.13 on Windows so we will pin
# windows builds to libxslt 1.1.34 and libxml2 2.9.10 for now and followup later with the
# work to fix that issue in IPACK-145.
override "libxml2", version: windows? ? "2.9.10" : "2.9.13"
override "libxslt", version: windows? ? "1.1.34" : "1.1.35"

override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "6.3"
override :openssl, version: "1.1.1t" if mac_os_x?
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "3.1.2"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "ruby-msys2-devkit", version: "3.1.2-1"
override "rust", version: "1.37.0"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"

