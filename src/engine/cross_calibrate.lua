-- src/engine/cross_calibrate.lua - cross-calibration engine
--
--     Copyright (C) 2026  Kıvılcım İpek Afet Öztürk
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
local lfs = require("lfs")

local function get_mtime(path)
   if not path then return 0 end
   local attr = lfs.attributes(tostring(path))
   if attr and attr.modification then
      return attr.modification
   end
   return 0
end

function lament.engine.cross_calibrate()
   local init_result = true
   local result = true

   -- Load backend module registry
   for i = 1, #const.globals._MODULES do
      local _init_result, _err = const.globals._MODULES[i]:init()
      init_result = _init_result and init_result
      if not _init_result and err then
         log.error(err)
      end
   end

   local lament_conf_path = const.config.DEFAULT_AUTOCONF_PATH[1]
   local lament_mtime = get_mtime(lament_conf_path)

   -- Invoke application or recalibration based on mtime
   for i = 1, #const.globals._MODULES do
      local module = const.globals._MODULES[i]
      local mod_mtime = get_mtime(module.path)

      if mod_mtime > lament_mtime then
         log.info("System config (" .. tostring(module.path) .. ") is newer. Recalibrating into LAMENT.")
         local _result, err = module:recalibrate(const.globals._SYSCONF)
         result = result and _result
      elseif lament_mtime > mod_mtime then
         log.info("LAMENT config (" .. tostring(lament_conf_path) .. ") is newer. Applying to system.")
         local _result, err = module:apply(const.globals._SYSCONF)
         result = result and _result
      else
         log.info("Configs are in sync for module: " .. tostring(module.name))
      end
   end

   return result
end

return lament.engine.cross_calibrate
