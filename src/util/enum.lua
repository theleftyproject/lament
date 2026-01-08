-- enum.lua - provides discriminated unions
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

--- Enums and discriminated unions
local enum = {}

local function inner(key)
   return function(data)
      local tbl = {
         key = key
      }

      if type(data) == 'table' then
         for i, v in pairs(data) do
            tbl[i] = v
         end
      else
         tbl.inner = data
      end

      return setmetatable(tbl, { __call = function() return data end })
   end
end

---Instantiates a new [lament.util.enum.Enum]
---@param ... unknown List of keys in the enum
---@return table Enum The enum table
function enum.Enum(...)
   local tbl = {}

   for i = 1, select('#', ...) do
      local key = select(i, ...)

      tbl[key] = inner(key)
   end

   return tbl
end
function enum.is_variant(value, variant)
  return type(value) == "table" and value.key == variant
end

return enum
