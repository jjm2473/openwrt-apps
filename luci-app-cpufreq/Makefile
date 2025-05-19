
include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI for misc configure
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+ethtool
PKG_VERSION:=1.8.6-r3
PKG_RELEASE:=

define Package/luci-app-cpufreq/conffiles
/etc/config/cpufreq
/etc/config/tuning
/etc/config/tuning_boot
/etc/config/tuning_net
endef

include ../luci-alias.mk

# call BuildPackage - OpenWrt buildroot signature
