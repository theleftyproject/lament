-- sandbox.lua - Sandboxed environment for running lament commands
--
--     Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
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

local lament = require("lament")
lament.sandbox = {}

local env = require("proxy")

function lament.sandbox.apply_module(module_path)
      local f, err = loadfile(module_path, "t", env)
      if not f then
         error(err)
      end
      if not f["apply"] then
---@diagnostic disable-next-line: undefined-field
         return f.apply()
      end
      return error("this backend lacks an apply field")
end

function lament.sandbox.recalibrate_module(module_path)
      local f, err = loadfile(module_path, "t", env)
      if not f then
         error(err)
      end
      if not f["recalibrate"] then
---@diagnostic disable-next-line: undefined-field
         return f.recalibrate()
      end
      return error("this backend lacks a recalibrate field")
end
