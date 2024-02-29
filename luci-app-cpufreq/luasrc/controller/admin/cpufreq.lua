--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

module("luci.controller.admin.cpufreq",package.seeall)
require "luci.util"

function index()
  local sys = require "luci.sys"
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
  if nixio.fs.access("/etc/config/samba4") then
    defaultpage = defaultpage or alias("admin", "system", appname, "samba")
    entry({"admin", "system", appname, "samba"}, cbi("cpufreq/samba"), _("Samba"), 3).leaf = true
  end
  defaultpage = defaultpage or alias("admin", "system", appname, "boot")
  entry({"admin", "system", appname, "boot"}, cbi("cpufreq/boot"), _("Boot"), 4).leaf = true

  if nixio.fs.access("/etc/config/kmods") and sys.call("[ -n \"$(ls /etc/modules-pending.d/ 2>/dev/null | head -c1)\" ] >/dev/null 2>&1") == 0 then
    entry({"admin", "system", appname, "kmods"}, cbi("cpufreq/kmods"), _("Drivers"), 5).leaf = true
  end

  if sys.call("[ -d /ext_overlay ] >/dev/null 2>&1") == 0 then
    entry({"admin", "system", appname, "sandbox"}, call("sandbox_index", 
        {prefix=luci.dispatcher.build_url("admin", "system", appname, "sandbox")}), _("Sandbox"), 6)
    entry({"admin", "system", appname, "sandbox", "reset"}, post("sandbox_reset"))
    entry({"admin", "system", appname, "sandbox", "commit"}, post("sandbox_commit"))
    entry({"admin", "system", appname, "sandbox", "exit"}, post("sandbox_exit"))
  end

  local hwppoe_feature = luci.util.trim(sys.exec("ethtool -k eth0 2>/dev/null | grep -F hw-pppoe: 2>/dev/null"))
  if hwppoe_feature ~= nil and hwppoe_feature ~= "" and not string.match(hwppoe_feature, "%[fixed%]") then
    entry({"admin", "system", appname, "net"}, cbi("cpufreq/net"), _("Network"), 7).leaf = true
  end

  if nixio.fs.access("/etc/init.d/grub") then
    entry({"admin", "system", appname, "cmdline"}, cbi("cpufreq/cmdline"), _("Kernel Cmdline"), 8).leaf = true
  end

  if defaultpage then
    entry({"admin", "system", appname}, defaultpage, _("Tuning"), 59)
  end

end

function get_cpu_info()
  local fs = require "nixio.fs"
  local freq = tonumber(fs.readfile("/sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq")) / 1000; -- MHz
  luci.http.status(200, "ok")
  luci.http.prepare_content("application/json")
  luci.http.write_json({freq=freq})
end

function sandbox_index(param)
  luci.template.render("cpufreq/sandbox", {prefix=param.prefix})
end

function sandbox_reset()
  local sys = require "luci.sys"
  sys.call("/usr/sbin/sandbox reset")
  luci.sys.reboot()
end

function sandbox_commit()
  local sys = require "luci.sys"
  sys.call("/usr/sbin/sandbox commit")
  luci.sys.reboot()
end

function sandbox_exit()
  local sys = require "luci.sys"
  sys.call("/usr/sbin/sandbox exit")
  luci.sys.reboot()
end
