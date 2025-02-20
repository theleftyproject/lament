-- backend.lua - defines backend API functions
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

local lament = require('lament')
local lament_hive = require('lament.hive')
local lpeg = require('lpeg')
local lfs = require('lfs')

--- defines a LAMENT backend
lament.backend.Backend = {}

--- creates a new LAMENT backend
---
--- @param name string The name for the backend
--- @return table lament.backend.Backend the newly created backend
function lament.backend.Backend.new(name)
   return setmetatable({
      --- The name for the backend
      name = name,
      --- Whether the backend is active or not
      active = false,
      --- The hives registered by the backend
      hives = {},
      --- The files demanded by the backend
      files = {},
      --- The capabilities of the backend
      -- TODO: add permissions to backends, like accessing
      -- systemd commands or just editing files
      capabilities = {},
      ---defines the behaviour of the bakckend on initialization.
      ---@param backend table the backend being initialized
      ---@param hives table the hives the backend will register
      ---@param files table the files the backend will access
      ---@return boolean success whether activation was successful or not.
      on_init = function (backend, hives, files) return true end,
      on_exit = function (backend, hives, files) return true end,
   }, {__index = lament.backend.Backend})
end

--- Initializes the backend
--- The function merely calls the `on_init` function of the backend
--- and sets `active` to `true`
function lament.backend.Backend:init()
   if self:on_init(self.hives, self.files) then
      self.active = true
   end
   return self
end

--- Shuts the backend down
---@return table
function lament.backend.Backend:exit()
   if self:on_exit(self.hives, self.files) then
      self.active = false
   end
   return self
end

--- Forwards-applies the configuration as specified by the backend
function lament.backend.Backend:apply()
   return true
end

--- Backwards-applies the configuration as specified by the backend
function lament.backend.Backend:recalibrate()
   return true
end
