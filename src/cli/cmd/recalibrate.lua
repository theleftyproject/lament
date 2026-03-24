-- src/cli/cmd/recalibrate.lua - recalibration command
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
local engine = require("engine")
local log = require("log")
require("engine.recalibrate")

local function recalibrate(parsed)
   log.info("Starting configuration recalibration...")
   local result = engine.recalibrate()
   if result then
      log.info("Recalibration successful.")
      return 0
   else
      log.error("Recalibration failed.")
      return 1
   end
end

return recalibrate
