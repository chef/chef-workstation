# DO NOT MODIFY
# The ChefDK, delivery-cli, and workstation app versions are pinned by Expeditor.
# Whenever ChefDK is promoted to stable or workstation app and delivery cli are merged
# to master then Expeditor takes that version, runs a script to replace it here and pushes
# a new commit / build through.
override :"chef-dk", version: "v4.0.14"
override "delivery-cli", version: "0.0.52"
override "chef-workstation-app", version: "v0.1.7"
# /DO NOT MODIFY

# DK's overrides; god have mercy on my soul
# This comes from DK's ./omnibus_overrides.rb
# If this stays, may need to duplicate that file and the rake
# tasks for updating dependencies
override :rubygems, version: "3.0.3"
override :bundler, version: "1.17.3"
override "libffi", version: "3.2.1"
override "libiconv", version: "1.15"
override "liblzma", version: "5.2.4"
override "libtool", version: "2.4.2"
override "libxml2", version: "2.9.9"
override "libxslt", version: "1.1.30"
override "libyaml", version: "0.1.7"
override "makedepend", version: "1.0.5"
override "ncurses", version: "5.9"
override "pkg-config-lite", version: "0.28-1"
override "ruby", version: "2.6.2"
override "ruby-windows-devkit-bash", version: "3.1.23-4-msys-1.0.18"
override "util-macros", version: "1.19.0"
override "xproto", version: "7.0.28"
override "zlib", version: "1.2.11"
override "libzmq", version: "4.0.7"
override "openssl", version: "1.0.2r"
override "rust", version: "1.32.0"

# For workstation app
override "nodejs", version: "10.9.0"
