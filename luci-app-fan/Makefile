# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI fan control
LUCI_DEPENDS:=+coreutils-stat
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.0-r3
PKG_RELEASE:=
PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

define Package/luci-app-fan/conffiles
/etc/config/luci-fan
endef

include ../luci-alias.mk

# call BuildPackage - OpenWrt buildroot signature

