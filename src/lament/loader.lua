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
local effil = require('effil')

-- TODO: load lament backends from /usr/share/lament/backends
-- TODO: load lament recipes from /etc/lament/
