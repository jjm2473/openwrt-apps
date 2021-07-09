--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

require "luci.util"

local governor_path = "/sys/devices/system/cpu/cpufreq/policy0/scaling_governor"

local fs = require "nixio.fs"

-- Use (non-UCI) SimpleForm since we have no related config file
m = SimpleForm("cpufreq", translate("CPU Frequence"), translate("Manage CPU Frequence over LuCI."))
m:append(Template("cpufreq/cpuinfo"))
-- disable submit and reset button
m.submit = false
m.reset = false

s = m:section(SimpleSection)

local cur_governor = luci.util.trim(fs.readfile(governor_path))

local governor = s:option(ListValue, "_governor", translate("Governor"))
for i,v in pairs(luci.util.split(luci.util.trim(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors")), " ")) do
  governor:value(v, translate(v));
end
governor.default = cur_governor
governor.write = function(self, section, value)
  cur_governor = value
end

local apply = s:option(Button, "_apply")
apply.render = function(self, section, scope)
  self.title = " "
  self.inputtitle = translate("Apply")
  self.inputstyle = "edit"
  Button.render(self, section, scope)
end
apply.write = function(self, section, value)
  fs.writefile(governor_path, cur_governor .. "\n")
  luci.http.redirect(luci.dispatcher.build_url("admin/system/cpufreq"))
end

return m