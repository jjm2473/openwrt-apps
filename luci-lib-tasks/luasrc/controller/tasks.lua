
module("luci.controller.tasks", package.seeall)


function index()
  entry({"admin", "system", "tasks"}, alias("admin", "system", "tasks", "all"), _("Tasks"), 56)
  --entry({"admin", "system", "tasks", "user"}, cbi("tasks/user"), _("User Tasks"), 1)
  entry({"admin", "system", "tasks", "all"}, form("tasks/all"), _("All Tasks"), 2)
  entry({"admin", "system", "tasks", "status"}, call("tasks_status"))
  entry({"admin", "system", "tasks", "log"}, call("tasks_log"))
  entry({"admin", "system", "tasks", "stop"}, post("tasks_stop"))
end

local util  = require "luci.util"
local jsonc = require "luci.jsonc"
local ltn12 = require "luci.ltn12"

local taskd = require "luci.model.tasks"

function tasks_status()
  local data = taskd.status(luci.http.formvalue("task_id"))
  luci.http.prepare_content("application/json")
  luci.http.write_json(data)
end

function tasks_log()
  local task_id = luci.http.formvalue("task_id")
  local offset = luci.http.formvalue("offset")
  offset = offset and tonumber(offset) or 0
  local logpath = "/var/log/tasks/"..task_id..".log"
  local i
  local logfd = io.open(logpath, "rb")
  if logfd == nil then
    luci.http.status(404)
    luci.http.write("log not found")
    return
  end

  local size = logfd:seek("end")

  if size < offset then
    luci.http.status(205, "Reset Content")
    luci.http.write("reset offset")
    return
  end

  i = 0
  while (i<200)
  do
    if size > offset then
      break
    end
    nixio.nanosleep(0, 10000000) -- sleep 10ms
    size = logfd:seek("end")
    i = i+1
  end
  if i == 200 then
    logfd:close()
    luci.http.status(204)
    luci.http.prepare_content("application/octet-stream")
    return
  end
  logfd:seek("set", offset)

  local write_log = function()
    local buffer = logfd:read(4096)
    if buffer and #buffer > 0 then
        return buffer
    else
        logfd:close()
        return nil
    end
  end

  luci.http.prepare_content("application/octet-stream")

  if logfd then
    ltn12.pump.all(write_log, luci.http.write)
  end
end

function tasks_stop()
  local os = require "os"
  local task_id = luci.http.formvalue("task_id") or ""
  if task_id == "" then
    luci.http.status(400)
    luci.http.write("task_id is empty")
    return
  end
  local r = os.execute("/etc/init.d/tasks task_del "..task_id.." >/dev/null 2>&1")
  luci.http.status(204)
end