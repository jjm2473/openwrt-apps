--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

local m, s, o

m = Map("tuning", nil, translate("Select IPK Mirror server"))

s = m:section(TypedSection, "ipk")
s.addremove=false
s.anonymous=true

o = s:option(ListValue, "mirror", translate("Mirror server"))
o:value("disable", "")
o:value("http://downloads.openwrt.org/", translate("OpenWRT") .. " (HTTP)")
o:value("https://downloads.openwrt.org/", translate("OpenWRT") .. " (HTTPS)")
o:value("https://mirrors.cernet.edu.cn/openwrt/", translate("CERNET 302"))
o:value("https://mirrors.sustech.edu.cn/openwrt/", translate("SUSTech"))
o:value("https://mirrors.tuna.tsinghua.edu.cn/openwrt/", translate("Tsinghua University"))
o:value("https://mirrors.ustc.edu.cn/openwrt/", translate("USTC"))
o:value("https://mirror.lzu.edu.cn/openwrt/", translate("Lanzhou University"))
o:value("https://mirrors.aliyun.com/openwrt/", translate("Alibaba Cloud"))
o:value("https://mirrors.cloud.tencent.com/openwrt/", translate("Tencent Cloud"))
o:value("https://mirror.iscas.ac.cn/openwrt/", translate("Chinese Academy of Sciences"))
o:value("https://mirror.nyist.edu.cn/openwrt/", translate("NYIST"))
o:value("https://mirror.sjtu.edu.cn/openwrt/", translate("SJTU"))
o:value("https://mirrors.cqupt.edu.cn/openwrt/", translate("CQUPT"))
o:value("https://mirrors.qlu.edu.cn/openwrt/", translate("Qilu University of Technology"))

o.rmempty = false
o.default = "disable"

return m
