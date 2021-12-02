--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

require "luci.util"
module("luci.controller.admin.cpufreq",package.seeall)

function index()
  local appname = "tuning"
  local defaultpage = nil
  entry({"admin", "system", appname}).dependent = true
  if nixio.fs.access("/sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq") then
    defaultpage = defaultpage or alias("admin", "system", appname, "main")
    entry({"admin", "system", appname, "main"}, cbi("cpufreq/main"), _("CPU Tuning"), 1).leaf = true
    entry({"admin", "system", appname, "get_cpu_info"}, call("get_cpu_info"), nil).leaf = true
  end
  if nixio.fs.access("/rom/etc/opkg/distfeeds.conf") then
    defaultpage = defaultpage or alias("admin", "system", appname, "ipk")
    entry({"admin", "system", appname, "ipk"}, cbi("cpufreq/ipk"), _("IPK Mirror"), 2).leaf = true
  end

  if defaultpage then
    entry({"admin", "system", appname}, defaultpage, _("Tuning"), 59)
  end

end

function get_cpu_info()
  local fs = require "nixio.fs"
  -- fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_governor")
  -- local util = require "luci.util"; util.split(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors"), " ")
  local freq = tonumber(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq")) / 1000; -- MHz
  local temp = tonumber(fs.readfile("/sys/class/thermal/thermal_zone0/temp")) / 1000; -- ˚C
  luci.http.status(200, "ok")
  luci.http.prepare_content("application/json")
  luci.http.write_json({freq=freq, temp=temp})
end
