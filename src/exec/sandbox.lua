---@diagnostic disable: undefined-field
-- local sandbox = require("sandbox")
local lament = require("lament")
lament.sandbox = {}

--- the environment that is not being masqueraded
-- TODO: masquerade a controlled environment
local env = {
    math = math, string = string, table = table,
    lpeg = require("lpeg"),
    http = require("socket.http"),
    io = { open = io.open, read = io.read, write = io.write },
    os = { time = os.time, date = os.date, difftime = os.difftime, execute = os.execute }
}

--- The masqueradae environment
local masq_env = {}

-- Functions that do not need authorization
masq_env.math = env.math
masq_env.string = env.string
masq_env.table = env.table
masq_env.lpeg = env.lpeg
-- Functions that do need authorization
-- TODO: Implement authorization and logging for these functions
masq_env.http = {}
masq_env.io = {}
masq_env.os = {}

function lament.sandbox.apply_module(module_path)
      local f, err = loadfile(module_path, "t", masq_env)
      if not f then
         error(err)
      end
      if f["apply"] == nil then
         return f.apply()
      end
      return error("this backend lacks an apply field")
end

function lament.sandbox.recalibrate_module(module_path)
      local f, err = loadfile(module_path, "t", masq_env)
      if not f then
         error(err)
      end
      if f["recalibrate"] == nil then
         return f.recalibrate()
      end
      return error("this backend lacks a recalibrate field")
end
