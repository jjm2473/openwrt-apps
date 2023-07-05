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

o = s:option(ListValue, "governor", translate("CPUFreq governor"), translate("It is recommended to use 'ondemand' or 'schedutil'"))
o:value("", translate("Default (Take effect after reboot)"))
for i,v in pairs(luci.util.split(luci.util.trim(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors")), " ")) do
  o:value(v, translate(v))
end
o.default = cur_governor

local available_frequencies = luci.util.split(luci.util.trim(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies")), " ")

if #available_frequencies > 0 then
  o = s:option(ListValue, "speed", translate("Frequency"), translate("Pay attention to heat dissipation when choosing high frequency"))
  o:depends("governor", "userspace")
  for i,v in pairs(available_frequencies) do
    o:value(v, (tonumber(v)/1000) .. " MHz")
  end
  o.rmempty = true
  o.default = available_frequencies[1]
end

return m
