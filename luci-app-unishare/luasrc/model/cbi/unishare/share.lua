
local uci = luci.model.uci.cursor()

local users = {}
uci:foreach("unishare", "user", function(e)
    users[#users+1] = e["username"]
end)

m = Map("unishare", translate("Configure Share"))
m.redirect = luci.dispatcher.build_url("admin", "nas", "unishare", "index")
function m.on_save()
    luci.http.redirect(m.redirect)
end

s = m:section(NamedSection, arg[1], "share", "")
s.addremove = false
s.dynamic = false

o = s:option(Value, "path", translate("Path"))
o.type = "path"
o.rmempty = false

o = s:option(Value, "name", translate("Name"))
o.rmempty = true

o = s:option(StaticList, "rw", translate("Read/Write Users"),
    translatef("'Everyone' includes anonymous if enabled, 'Logged Users' includes all users configured in '%s' tab", 
        "<a href=\""..luci.dispatcher.build_url("admin", "nas", "unishare", "users").."\" >"..translate("Users").."</a>"))
o:value("everyone", translate("Everyone"))
o:value("users", translate("Logged Users"))
for k, u in pairs(users) do
    o:value(u)
end

o = s:option(StaticList, "ro", translate("Read Only Users"))
o:value("everyone", translate("Everyone"))
o:value("users", translate("Logged Users"))
for k, u in pairs(users) do
    o:value(u)
end

o = s:option(StaticList, "proto", translate("Protocol"))
o:value("samba", "Samba")
o:value("webdav", "WebDAV")

return m
