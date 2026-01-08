-- switch.lua - Provides switch statement
--
--     Copyright (C) 2024 - 2026  Sylviettee, Sparkles-Laurel
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


--- Determines which case to take
--- @param val any
--- @return function
local function switch(val)
   return function(cases)
      for values, fn in pairs(cases) do
         if values == 'default' then
            goto continue
         end

         for i = 1, #values do
            if val == values[i] then
               return fn()
            end
         end

         ::continue::
      end

      if cases.default then
         cases.default()
      end
   end
end
--- Implements branches for `switch`
--- @param ... unknown The cases to match against
--- @return unknown[] an acceptable value for `switch`
local function case (...)
   return { ... }
end

return {
   switch = switch,
   case = case
}
