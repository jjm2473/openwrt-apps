--[[
LuCI - Lua Configuration Interface
Copyright 2021 jjm2473
]]--

require "luci.util"
module("luci.controller.admin.ota",package.seeall)

function index()
  entry({"admin", "system", "ota"}, call("action_ota"), _("OTA"), 69)
  entry({"admin", "system", "ota", "check"}, post("action_check"))
  entry({"admin", "system", "ota", "download"}, post("action_download"))
  entry({"admin", "system", "ota", "progress"}, call("action_progress"))
  entry({"admin", "system", "ota", "cancel"}, post("action_cancel"))
end

local function ota_exec(cmd)
  local nixio = require "nixio"
  local os   = require "os"
  local fs   = require "nixio.fs"
  local rshift  = nixio.bit.rshift

  local oflags = nixio.open_flags("wronly", "creat")
  local lock, code, msg = nixio.open("/var/lock/ota_api.lock", oflags)
  if not lock then
    return 255, "", "Open stdio lock failed: " .. msg
  end

  -- Acquire lock
  local stat, code, msg = lock:lock("tlock")
  if not stat then
    lock:close()
    return 255, "", "Lock stdio failed: " .. msg
  end

  local r = os.execute(cmd .. " >/var/log/ota.stdout 2>/var/log/ota.stderr")
  local e = fs.readfile("/var/log/ota.stderr")
  local o = fs.readfile("/var/log/ota.stdout")

  fs.unlink("/var/log/ota.stderr")
  fs.unlink("/var/log/ota.stdout")

  lock:lock("ulock")
  lock:close()

  e = e or ""
  if r == 256 and e == "" then
    e = "os.execute failed, is /var/log full or not existed?"
  end
  return rshift(r, 8), o or "", e or ""
end

function action_ota()
	luci.template.render("admin_system/ota")
end

function action_check()
  local r,o,e = ota_exec("ota check")
  local ret = {
    code = 500,
    msg = "Unknown"
  }
  if r == 0 then
    ret.code = 0
    ret.msg = o
  elseif r == 1 then
    ret.code = 1
    ret.msg = "Already the latest firmware"
  else
    ret.code = 500
    ret.msg = e
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(ret)
end

function action_download()
  local r,o,e = ota_exec("ota download")
  local ret = {
    code = 500,
    msg = "Unknown"
  }
  if r == 0 then
    ret.code = 0
    ret.msg = ""
  else
    ret.code = 500
    ret.msg = e
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(ret)
end

function action_progress()
  local r,o,e = ota_exec("ota progress")
  local ret = {
    code = 500,
    msg = "Unknown"
  }
  if r == 0 then
    ret.code = 0
    ret.msg = "done"
  elseif r == 1 or r == 2 then
    ret.code = r
    ret.msg = o
  else
    ret.code = 500
    ret.msg = e
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(ret)
end

function action_cancel()
  local r,o,e = ota_exec("ota cancel")
  local ret = {
    code = 500,
    msg = "Unknown"
  }
  if r == 0 then
    ret.code = 0
    ret.msg = "ok"
  else
    ret.code = 500
    ret.msg = e
  end
  luci.http.prepare_content("application/json")
  luci.http.write_json(ret)
end
