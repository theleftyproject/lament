-- src/hive/key.lua - configuration keys
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

local class = require("pl.class")

local Key = class()

function Key:_init(name, opts)
  self.name = name
  self.default = opts.default
  self.validate = opts.validate or function(_) return true end
end

function Key:get(hive)
  return rawget(hive._values, self.name) or self.default
end

function Key:set(hive, value)
  assert(self.validate(value), "Validation failed for key: " .. self.name)
  hive._values[self.name] = value
end

return { Key = Key }
