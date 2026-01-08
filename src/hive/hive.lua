-- src/hive/hive.lua - configuration hives
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

local class = require("pl.class")

local Hive = class()

function Hive:_init(name)
  self.name = name
  self._keys = {}
  self._values = {}
end

function Hive:register_key(key)
  self._keys[key.name] = key
end

function Hive:get_keys()
  return self._keys
end

function Hive:__index(keyname)
  local key = self._keys[keyname]
  if key then
    return key:get(self)
  else
    return rawget(getmetatable(self), keyname)
  end
end

function Hive:__newindex(keyname, value)
  local key = self._keys[keyname]
  if key then
    key:set(self, value)
  else
    rawset(self, keyname, value)
  end
end

return { Hive = Hive }
