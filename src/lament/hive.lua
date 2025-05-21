-- hive.lua - defines LAMENT configuration hives
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

local lament = require('lament')
local pl = require('pl')
--- Defines a configuration hive.
lament.Hive = pl.class()

--- Creates a new instance of a hive.
---@param name string The name of the hive.
---@param default_keys table The default values of the key sets
function lament.Hive:_init(name, default_keys)
      self.name = name
      self.keys = default_keys
end

--- Reads a hive key.
--- @param key string The name of the key to read
--- @return table? Key the key that was read
function lament.Hive:get_key(key)
   -- if the key exists, return its value
   if self.keys[key] then
      return self.keys[key]
   end

   -- else return null
   return nil
end

--- Sets the value for a key in a hive.
--- @param key string The name of the key to set.
--- @param value table The value of the config key.
--- @return table Hive This configuration hive.
function lament.Hive:set_key(key, value)
   self.keys[key].value = value
   return self
end
