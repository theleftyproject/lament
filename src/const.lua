-- src/const.lua - Constants
--
--    Copyright (C) 2025 - 2026 Kıvılcım İpek Defne Öztürk
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
lament.const = {}
lament.const.config = {}
lament.const.config.DEFAULT_BACKEND_PATH = {
   "/usr/share/lament/backends"
}
lament.const.config.DEFAULT_AUTOCONF_PATH = {
   "/etc/lament/lament.conf.lua",
   "/etc/lament/self.conf.lua",
   "/etc/lament/auto.conf.lua"
}

-- WHY THE FUCK IS THIS HERE? IDK.
lament.globals = {}
--- The global system configuration object,
--- This represents the state S in the configuration theory
lament.globals._SYSCONF = {}
--- The effective configuration object
--- This represents the state E in the configuration theory
lament.globals._EFFSTAT = {}
--- Configuration modules. A backend may specify more than one module
lament.globals._MODULES = {}

return {
   --- Constants
   const = lament.const,
   --- Global variables
   globals = lament.globals
}
