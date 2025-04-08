-- executor.lua - responsible for execution of the tasks
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

local lament = require("lament")
require("lament.util.enum")
require("lament.loader")

lament.executor = {}

lament.executor.CeaseAnd = lament.enum(
   'halt',
   'load_last',
   'infer_from_effective',
   'infer_from_desired'
)

--- Starts calibration of the system according to the desired state
--- If the desired state is malconfigured, perform the appropriate action,
--- as defined by the key `cease_and` in the auto-config.
function lament.executor.start_application()
   -- Obtain cessation behavior
   local cease_and = lament._sysconf.lament.cease_and
   -- Prepare backends
   lament.boot_backends()
   -- TODO: finish the implementation of application initialization
end

function lament.executor.start_recalibration()
end

return lament.executor
