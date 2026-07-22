-- src/engine/recalibrate.lua - application engine
--
--     Copyright (C) 2024 - 2026  Kıvılcım İpek Afet Öztürk
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
local const = require("lament.const")
local log = require("lament.log")
local sandbox = require("lament.exec.sandbox")

function lament.engine.recalibrate()
   local result = true
   -- Load backend module registry
   for i = 1, #const.globals._MODULES do
      const.globals._MODULES[i]:init()
   end
   -- Invoke application
   for i = 1, #const.globals._MODULES do
      local module = const.globals._MODULES[i]
      local _result, err
      if module.path ~= nil then
         _result, err = sandbox.recalibrate_module(module.path)
      else
         _result, err = module:recalibrate(const.globals._SYSCONF)
      end
      if _result == nil and err == nil then
         _result = true
      end
      result = result and _result
      if err then
         log.error(err)
      end
   end
   return result
end

return lament.engine.recalibrate
