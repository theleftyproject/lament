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

function proxy.__index(keyname)
   if keyname == "print" then
      return hostenv.core.print
   elseif keyname == "error" then
      return hostenv.core.error
   elseif keyname == "math"  then
      proxy.print("math function is being called")
      return hostenv.math
   end
end

function proxy.os.__index(keyname)

end

function proxy.io.__index(keyname)

end

return proxy
