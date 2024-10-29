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

local conf_opts = {
   backend_location = "/usr/share/lament/backends",
   conf_dir = "/etc/lament",
   self_conf = "/etc/lament/self.conf.lua",
}

local active_backends = {}

local function walk_backend_dir()
   local backends = {}
   for i,file in ipairs(lfs.dir(conf_opts.backend_location)) do
      backends[#i + 1] = file
   end

   return backends
end

local function boot_backends()
   local backends = walk_backend_dir()
   for backend in backends do
      active_backends[backend] = {
       -- TODO: Boot up backend
      }
   end
end

local function walk_recipe_dir()
   local recipes = {}
   for i, recipe in ipairs(lfs.dir(conf_opts.conf_dir)) do
      recipes[#i + 1] = recipe
   end
end
