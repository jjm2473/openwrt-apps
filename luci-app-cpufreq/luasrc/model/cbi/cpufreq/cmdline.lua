--[[
LuCI - Lua Configuration Interface
Copyright 2024 jjm2473
]]--

require "luci.util"
require "luci.xml"
local fs = require "nixio.fs"

local m, s, o

m = Map("grub", nil, translate("This page configures Linux kernel boot parameters. After saving and applying, the GRUB configuration file of the boot partition will be modified. The parameters will take effect after restarting the system (the boot partition is not within the scope of sandbox protection, please be aware)"))
s = m:section(SimpleSection, translate("Current Cmdline"), luci.xml.pcdata(luci.util.trim(fs.readfile("/proc/cmdline") or "")))

if fs.access("/etc/grub.cfg.d/01-iommu.cfg") then
	s = m:section(NamedSection, "iommu", "iommu", "IOMMU", translate("Supports PCI device passthrough for virtual machines (KVM/QEMU)"))
	s.addremove=false
	s.anonymous=true

	o = s:option(Flag, "enabled", translate("Enabled"))

	o = s:option(Value, "cmdline", translate("Parameters"), translate("Default or empty will be automatically filled in according to the current platform"))
	o:value("", translate("Default"))
	o:value("intel_iommu=on iommu=pt", "Intel (intel_iommu=on iommu=pt)")
	o:value("amd_iommu=on iommu=pt", "AMD (amd_iommu=on iommu=pt)")

end

s = m:section(TypedSection, "cmdline", translate("Custom Parameters"),
	translate("Danger! If you do not understand the kernel boot parameters, do not modify them to avoid being unable to start or damaging the hardware"))
s.addremove=true
s.anonymous=true
s.template = "cbi/tblsection"

o = s:option(Flag, "enabled", translate("Enabled"))

o = s:option(Value, "cmdline", translate("Parameters"))
o.datatype = "string"
o.rmempty = false

o = s:option(Value, "comment", translate("Comment"))

return m
