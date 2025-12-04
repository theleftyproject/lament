-- src/interface/backend.lua - backends for configuration
--
--     Copyright (C) 2024-2025  Kıvılcım İpek Defne Öztürk
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

local class = require("pl.class")

local Backend = class()

function Backend:_init(path)
   --- Name of the backend
   self.name = "backend"
   --- Path of the backend
   self.path = path
   --- Hives the backend registers
   self.hives = {}
   --- Files the backend accesses
   self.open_files = {}
   self.active = false
end

function Backend:init()
   self.active = true
end

function Backend:quit()
   self.active = false
end

function Backend:apply()
   if not self.active then
      return
   end
end

function Backend:recalibrate()
   if not self.active then
      return
   end
end

return {
   Backend = Backend,
}
