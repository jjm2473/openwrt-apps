
m = Map("unishare")

s = m:section(TypedSection, "user", translate("Users"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Value, "username", translate("Username"))
o.type = "string"

o = s:option(Value, "password", translate("Password"))
o.password = true
o.rmempty = true

return m
