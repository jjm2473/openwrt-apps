--[[
LuCI - Lua Configuration Interface
Copyright 2022 jjm2473
]]--

local m, s, o

m = Map("tuning_net", nil, translate("Network"))

s = m:section(TypedSection, "hw_acct", translate("Hardware Acceleration"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hw_pppoe", translate("Enable PPPoE Acceleration"), translate("Improve PPPoE TX performace, only support built-in NICs"))
o.rmempty=true

return m
