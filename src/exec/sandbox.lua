-- exec/sandbox.lua - Sandboxed environment for execution
--
--     Copyright (C) 2025  Kıvılcım İpek Defne Öztürk
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
