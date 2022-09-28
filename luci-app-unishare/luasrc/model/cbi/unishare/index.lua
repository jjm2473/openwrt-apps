
m = Map("unishare")

s = m:section(TypedSection, "global", translate("Global"))
s:tab("general", translate("General Setup"))
s:tab("webdav", translate("WebDAV"))
s.anonymous = true
s.addremove = false

o = s:taboption("general", Flag, "enabled", translate("Enabled"))
o.default = 0

o = s:taboption("general", Flag, "anonymous", translate("Allow Anonymous"))
o.default = 0

o = s:taboption("webdav", Value, "webdav_port", translate("WebDAV Port"))
o.type = "port"

s = m:section(TypedSection, "share", translate("Shares"), translate("(The user marked in <b>Bold</b> has write access)"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin", "nas", "unishare", "share", "%s")
function s.create(...)
	local sid = TypedSection.create(...)
	luci.http.redirect(s.extedit % sid)
end

o = s:option(Value, "path", translate("Path"))
o.type = "path"
o.rmempty = false

o = s:option(Value, "name", translate("Name"))
o.rmempty = true

local function uci2string(v, s)
    if v == nil then
        return "&#8212;"
    end
    if type(v) == "table" then
        return table.concat(v, s)
    else
        return v
    end
end

o = s:option(DummyValue, "users", translate("Users"))
o.rawhtml = true
function o.cfgvalue(self, s)
	return "<b>" .. uci2string(self.map:get(s, "rw"), " ") .. "</b><br><i>" .. uci2string(self.map:get(s, "ro"), " ") .. "</i>"
end

o = s:option(StaticList, "proto", translate("Protocol"))
o:value("samba", "Samba")
o:value("webdav", "WebDAV")

return m
