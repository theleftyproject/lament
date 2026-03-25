-- src/cli/cmd/apply.lua - application command
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
require("engine.apply")

local function apply(parsed)
   log.info("Starting configuration application...")
   local result = engine.apply()
   if result then
      log.info("Application successful.")
      return 0
   else
      log.error("Application failed.")
      return 1
   end
end

return apply
