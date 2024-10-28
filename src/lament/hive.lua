-- hive.lua - defines LAMENT configuration hives
--
--     Copyright (C) 2024  Kıvılcım Defne Öztürk
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

local lament = require('src.lament')

-- defines a hive
local Hive = {}

-- instantiates a new Hive
function Hive.new(name, default_keys)
   return setmetatable({
      name = name,
      keys = default_keys
   }, {__index = Hive})
end

-- reads a hive key
function Hive:get_key(key)
   -- if the key exists, return its value
   if self[key] then
      return self[key]
   end

   -- else return null
   return nil
end

-- sets a hive key
function Hive:set_key(key, value)
   self[key] = value
   return self
end
