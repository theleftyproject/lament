-- perms.lua - Permissions
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
local bit = require("bit")

lament.exec = {
   perms = {}
}

--- Provides a list of permissions for a LAMENT backend.
lament.exec.perms.Permission = {
   --- Permission to read files
   read_file = bit.lshift(1, 0),
   --- Permission to write files
   write_file = bit.lshift(1, 1),
   --- Permission to execute external commands
   execute_external = bit.lshift(1, 2),
   --- Permission to make http requests
   access_http = bit.lshift(1, 3),
   --- Permission to do direct i/o
   direct_io = bit.lshift(1, 4),
   --- Permission to do raw socket i/o
   raw_socket_io = bit.lshift(1, 5),
   --- Permission to create files
   create_file = bit.lshift(1, 6),
   --- Permission to modify filesystem entries (rename, chmod, chown, etc)
   modify_file = bit.lshift(1, 7),
   --- Permission to control system services (on systemd, units)
   control_services = bit.lshift(1, 8),
   --- Permission to invoke arbitrary Lua code
   invoke_lua = bit.lshift(1, 9),
   --- Permission to invoke arbitrary C code
   invoke_dylink = bit.lshift(1, 10),
   --- Permission to make webdav requests
   access_webdav = bit.lshift(1, 11),
   --- Permission to access LPEG
   access_lpeg = bit.lshift(1, 12),
   --- Permission to execute as different users
   impersonate = bit.lshift(1, 13)
}

function lament.exec.perms.has_perm(perm_set, perm)
   return bit.band(perm_set, perm) ~= 0
end

function lament.exec.perms.grant_perm(perm_set, perm)
   return bit.bor(perm_set, perm)
end
