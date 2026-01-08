-- src/engine/apply.lua - application engine
--
--     Copyright (C) 2024 - 2026  Kıvılcım İpek Defne Öztürk
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
local sandbox = require("sandbox")

function lament.engine.apply()
   local init_result = true
   local _init_result = true
   local result = true
   local _result = true
   local err
   -- Load backend module registry
   for i = 1, #const.globals._MODULES do
      _init_result, err = const.globals._MODULES[i]:init()
      init_result = _init_result and init_result
      -- In case a module fails to initialize...
      if not init_result then
         -- Report the error regarding the initialization of the module
         log.error(err)
      end
   end
   -- Invoke application
   for i = 1, #const.globals._MODULES do
      _result, err = const.globals._MODULES[i]:apply(const.globals._SYSCONF)
      result = result and _result

   end

   return result
end


return lament.engine.apply
