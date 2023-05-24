--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

local m, s, o
require "luci.util"

local governor_path = "/sys/devices/system/cpu/cpufreq/policy0/scaling_governor"

local fs = require "nixio.fs"

m = Map("cpufreq", nil, translate("Manage CPU performance over LuCI."))
m:section(SimpleSection).template  = "cpufreq/cpuinfo"

s = m:section(TypedSection, "cpufreq")
s.addremove=false
s.anonymous=true

local cur_governor = luci.util.trim(fs.readfile(governor_path))

o = s:option(ListValue, "governor", translate("CPUFreq governor"))
for i,v in pairs(luci.util.split(luci.util.trim(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors")), " ")) do
  o:value(v, translate(v))
end
o.rmempty = false
o.default = cur_governor

return m
