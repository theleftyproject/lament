-- proxy.lua - proxies with authorization for backends to call.
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

local hostenv = {}
hostenv.core = {}
hostenv.core.math = math
hostenv.core.string = string
hostenv.core.table = table
hostenv.core.print = print
hostenv.core.error = error
hostenv.lpeg = require("lpeg")
hostenv.io = {}
hostenv.io.open = io.open
hostenv.io.close = io.close
hostenv.io.read = io.read
hostenv.io.write = io.write
hostenv.os = {}
hostenv.os.time = os.time
hostenv.os.date = os.date
hostenv.os.difftime = os.difftime
hostenv.os.execute = os.execute


local proxy = {}
proxy.io = {}
proxy.os = {}
proxy.http = {}

function proxy.__index(keyname)
   if keyname == "print" then
      return hostenv.core.print
   elseif keyname == "error" then
      return hostenv.core.error
   elseif keyname == "math"  then
      proxy.print("math function is being called")
      return hostenv.math
   elseif keyname == "lament" then
      return require("lament")
   end
   error("module is not authorized to use module or function " .. keyname)
end

function proxy.io.__index(keyname)
   if keyname == "open" then
      -- TODO: check if the module has the right to access
      -- this file
      return hostenv.io.open
   elseif keyname == "close" then
      return hostenv.io.close
   elseif keyname == "read" then
      -- TODO: check if the module has the right to
      -- read this file
      return hostenv.io.read
   elseif keyname == "write" then
      -- TODO: check if the module has the right to
      -- write to this file
      return hostenv.io.write
   end
   error("module is not authorized to use module or function io." .. keyname)
end

function proxy.os.__index(keyname)
   if keyname == "time" then
      return hostenv.os.time
   elseif keyname == "difftime" then
      return hostenv.os.difftime
   elseif keyname == "date" then
      return hostenv.os.date
   elseif keyname == "execute" then
      -- ACE VULNERABILITY SPOT HERE
      -- TODO: Authorize module to execute commands
      return hostenv.os.execute
   end
   error("module is not authorized to use module or function os." .. keyname)
end

return proxy
