--[[
LuCI - Lua Configuration Interface
Copyright 2023 jjm2473
]]--

local files = io.popen("ls /etc/modules-pending.d/", "r")
local ln, drivers = nil, {}

while ( true )
do
	ln = files:read("*l")
	if not ln or ln == "" then
		break
	end
	drivers[#drivers+1] = luci.util.trim(ln)
end

files:close()

local m, s, o, i, d

m = Map("kmods", nil, translate("Configure device drivers, kernel modules, etc. Changes here will take effect on next boot"))

s = m:section(NamedSection, "kmods", "global", translate("Drivers Settings"))
s.addremove=false
s.anonymous=true

local known = {
	['r8125'] = translate("Realtek r8125 driver"),
	['r8168'] = translate("Realtek r8168 driver"),
	['i915-oot'] = translate("Backported Intel GPU driver (i915-oot)"),
}

o = s:option(StaticList, "enable", translate("Enable additional drivers"), translate("Please do not choose a driver you do not understand. Choosing the wrong driver may cause the system to fail to start"))
for i, d in ipairs(drivers) do
	o:value(d, known[d] or d )
end

return m
