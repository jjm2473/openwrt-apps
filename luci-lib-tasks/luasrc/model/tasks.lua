local util  = require "luci.util"
local jsonc = require "luci.jsonc"

local taskd = {}

local function output(data)
    local ret={}
    ret.running=data.running
    if not data.running then
        ret.exit_code=data.exit_code
    end
    ret.command=data["command"] and data["command"][4] or '#'
    if data["data"] then
        ret.start=tonumber(data["data"]["start"])
        if not data.running and data["data"]["stop"] then
            ret.stop=tonumber(data["data"]["stop"])
        end
    end
    return ret
end

taskd.status = function (task_id)
  task_id = task_id or ""
  local data = util.trim(util.exec("/etc/init.d/tasks task_status "..task_id.." 2>/dev/null")) or ""
  if data ~= "" then
    data = jsonc.parse(data)
    if task_id ~= "" and not data.running and data["data"] then
      data["data"]["stop"] = util.trim(util.exec("/etc/init.d/tasks task_stop_at "..task_id.." 2>/dev/null")) or ""
    end
  else
    if task_id == "" then
      data = {}
    else
      data = {running=false, exit_code=255}
    end
  end
  if task_id ~= "" then
    return output(data)
  end
  local ary={}
  for k, v in pairs(data) do
    ary[k] = output(v)
  end
  return ary
end

return taskd
