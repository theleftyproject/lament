-- cli.lua - The LAMENT command-line tool
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

-- TODO: fix this shit

local os = require("os")
local io = require("io")
local argparse = require("argparse")

local parser = argparse("lament", "Apply or recalibrate LAMENT rules")

-- Dummy environment for the cli
local lamentenv = {
   backends = {
      [1] = {
         name = "dummy1",
         active = true,
         hives = {
            [1] = {
               name = "hive1",
               keys = {

               }
            }
         }
      },
      [2] = {

      },
      [3] = {

      },
   }
}

--- Entry point for the application
local function main()
   local uname_p = io.popen("uname -s")
   local os_name = "Unknown"
   if uname_p then
      os_name = uname_p:read("*a")
      uname_p:close()
   end

   local host_f = io.open("/etc/hostname", "r")
   local hostname = "localhost"
   if host_f then
      hostname = host_f:read("*a")
      host_f:close()
   end

   print("LAMENT 0.1.0-beta-1 for " .. os_name )
   print("Calibrating " .. hostname)
end

main()
