-- hooks.lua - LAMENT execution engine hooks
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

-- Infers state from the effective state (also referred to as the state of et-cetra in configuration theory)
local function infer_etc_hook()

end

-- Infers state from the desired state (also referred to as the state of the system in configuration theory)
local function infer_decl_hook()

end

-- Cross-infers based on the mtime of effective and desired states
local function cross_infer_hook()
end

-- Loads the last effective configuration state
local function load_last_hook()
end
