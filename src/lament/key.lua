-- key.lua - hive configuration keys
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

--- A key in a [Hive]
local Key = {
   name = "",
   value = {},
}

--- Creates a new instance of a `Key`
--- @param name string The name of the key
--- @param default_value any Default value for the keys
--- @return table The metatable for the new `Key` instance
Key.new = function(name, default_value)
   return setmetatable({
      name = name,
      value = default_value,
   }, {__index = Key})
end
