-- src/interface/registry.lua - the config registry
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

local class = require("pl.class")

local Registry = class()

function Registry:_init()
  self.hives = {}
end

function Registry:register_hive(name, hive)
  self.hives[name] = hive
end

function Registry:get_hive(name)
  return self.hives[name]
end

return { Registry = Registry }
