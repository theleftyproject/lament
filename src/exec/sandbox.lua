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
      local chunk, err = loadfile(module_path, "t", masq_env)
      if not chunk then
         error(err)
      end
      local mod = chunk()
      if mod and mod.apply then
         return mod:apply()
      end
      error("this backend lacks an apply field")
end

function lament.sandbox.recalibrate_module(module_path)
      local chunk, err = loadfile(module_path, "t", masq_env)
      if not chunk then
         error(err)
      end
      local mod = chunk()
      if mod and mod.recalibrate then
         return mod:recalibrate()
      end
      error("this backend lacks a recalibrate field")
end
