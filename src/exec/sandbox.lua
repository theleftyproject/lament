local sandbox = require("sandbox")
local lament = require("lament")
lament.sandbox = {}

local env = {
    math = math, string = string, table = table,
    lpeg = require("lpeg"),
    http = require("socket.http"),
    io = { open = io.open, read = io.read, write = io.write },
    os = { time = os.time, date = os.date, difftime = os.difftime }
}

function lament.sandbox.apply_module(module_path)
      local f, err = loadfile(module_path, "t", env)
      if not f then
         error(err)
      end
      if f["apply"] == nil then
         return f.apply()
      end
      return error("this backend lacks an apply field")
end

function lament.sandbox.recalibrate_module(module_path)
      local f, err = loadfile(module_path, "t", env)
      if not f then
         error(err)
      end
      if f["recalibrate"] == nil then
         return f.recalibrate()
      end
      return error("this backend lacks a recalibrate field")
end
