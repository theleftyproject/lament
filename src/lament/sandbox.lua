-- sandbox.lua - safe execution environment
--
--     Copyright (C) 2025 Kıvılcım Defne Öztürk
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

local raw = {
   os = require("os"),
   io = require("io"),
   debug = require("debug"),
   lpeg = require("lpeg"),
   lament = lament,
}

local function execute_protected(cmd)
   -- TODO: Add an authorization mechanism
   print("[UNSAFE] Executing command: \"" .. cmd .. "\"")
   return raw.os.execute(cmd)
end

local function open_protected(file, mode)
   -- TODO: Add an authorization mechanism
   print("[UNSAFE] Opening file \""..file.."\" with mode \""..mode.."\"")
   return raw.io.open(file, mode)
end

local function close_protected(file)
   -- TODO: Add an authorization mechanism and more elegant logging
   print("[UNSAFE] Closing a file")
   return raw.io.close(file)
end

local function flush_protected()
   print("[UNSAFE] Flushing")
   return raw.io.flush()
end

--- The Lefty Safe Environment for LAMENT
-- TODO: Implement the safe environment
local lefty_safeenv = {
   os = {},
   io = {},
   debug = {},
   lpeg = {},
   lament = {},
}
lament.sandbox.safeenv = lefty_safeenv

return lament.sandbox
