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
local lpeg = require("lpeg")

--- Sandboxed environment for LAMENT modules and scripts
lament.backend.sandbox = {}

--- Installs a module call interceptor.
local function setup_interceptor(module_name)
   local og_module = _G[module_name]
   if type(og_module) ~= "table" then return end -- Skip if we are not intercepting a table

   local intercepted_module = {}
   setmetatable(intercepted_module, {
      __index = function (_, k)
         local og_function = og_module[k]
         -- TODO: Add permission check to call interception
         if type(og_function) == "function" then
            return function(...)
               print(string.format("[Call Interceptor] %s.%s called with:", module_name, k), ...)
               local result = { og_function(...) }
               print(string.format("[Call Interceptor] %s.%s returned", module_name, k))
               return table.unpack(result)
            end
         else
            return og_function
         end
      end
   })

   _G[module_name] = intercepted_module
end

setup_interceptor(io)
setup_interceptor(debug)
setup_interceptor(os)
setup_interceptor(lpeg)

return lament.backend.sandbox
