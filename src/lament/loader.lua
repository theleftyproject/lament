-- loader.lua - loads LAMENT config modules
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


-- how in the lesbians do I fucking load Lua bytecode in
-- from other Lua bytecode?

local lament = require('lament')
local sandbox = require('sandbox')
local lfs = require('lfs')

--- global configuration options
lament.conf_opts = {
   -- location of backends
   backend_location = "/usr/share/lament/backends",
   -- location of declarative config files
   conf_dir = "/etc/lament",
   -- the auto-configuration
   self_conf = "/etc/lament/self.conf.lua",
}
-- @todo load these from self.conf.lua and the environment

--- Table of LAMENT backends
lament.backends = {}

--- Table of active LAMENT backends that are running
lament.backends.active = {}

-- Table of LAMENT recipes
lament.recipes = {}

--- Walks through the backends directory specified in the configuration options
--- @return table? backends, any errors List of the backends available to LAMENT, and errors
function lament.backends.walk_backend_dir()
   local backends = {}
   -- walk through the backends directory
   for i,file in ipairs(lfs.dir(lament.conf_opts.backend_location)) do
      -- load file
      local backend_file, err = io.open(file, "rb")
      if err ~= nil then
         return nil, err
      elseif not backend_file then
         goto continue
      else
         local bytecode = backend_file:read("*a")
         if not bytecode then
            return nil, {
               message = string.format("failed to execute \"%s\"", file),
               position = {
                  line = debug.getinfo(2, "l").currentline,
                  file = debug.getinfo(2, "S").source,
               },
            }
         end
         -- register the backend
         local backend = nil
         -- @todo add error handling here
         backends[#i + 1] = backend
      end
       ::continue::
   end

   return backends, nil
end

--- Walks through a recipes directory specified in the configuration
local function walk_recipe_dir()
   for i, recipe in ipairs(lfs.dir(lament.conf_opts.conf_dir)) do
      lament.recipes[#i + 1] = recipe
   end
end
