# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI mac to vendor map
LUCI_DESCRIPTION:=provide a js for mac address to vendor mapping
LUCI_PKGARCH:=all

PKG_VERSION:=1.0.0-r2
# PKG_RELEASE MUST be empty for luci.mk
PKG_RELEASE:=

LIB_VERSION:=1.0.2
PKG_HASH:=519ddb8a7a4d3b0e9b2fa5f01ffc7a20ef3af80201d6630c3fffc05e7374e0af

PKG_SOURCE_URL_FILE:=v$(LIB_VERSION).tar.gz
PKG_SOURCE:=mac_vendor-$(PKG_SOURCE_URL_FILE)
PKG_SOURCE_URL:=https://github.com/jjm2473/mac_vendor/archive/refs/tags

PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

TARGET_CONFIGURE_OPTS= LIB_DIST="$(BUILD_DIR)/mac_vendor-$(LIB_VERSION)/dist" LIB_VERSION="$(LIB_VERSION)"
TARGET_CONFIGURE_OPTS+= SED="$(SED)"

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

