-- src/log.lua - Logger
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
local terminal = require("terminal")

-- Boot terminal
terminal.initialize({
   filehandle = io.stdout
})

lament.log = {}

lament.log.colors = {
   error = terminal.text.color.fore_seq(255, 0, 0),
   warn = terminal.text.color.fore_seq(255, 127, 0),
   info = terminal.text.color.fore_seq(100, 100, 255),
   debug = terminal.text.color.fore_seq(0, 255, 255),
   reset = "\033[m",
}

local headers = {
   error = "[" .. lament.log.colors.error .. "ERROR" .. lament.log.colors.reset .. "]",
   warn = "[" .. lament.log.colors.warn .. "WARN " .. lament.log.colors.reset .. "]",
   info = "[" .. lament.log.colors.info .. "INFO " .. lament.log.colors.reset .. "]",
   debug = "[" .. lament.log.colors.debug .. "DEBUG" .. lament.log.colors.reset .. "]",
}

---Logs an error level message
---@param msg string the format of the message to log,
function lament.log.error(msg, ...)
   return terminal.output.write(headers.error .. " " .. msg, ...)
end

---comment
---@param msg any
---@param ... unknown
---@return unknown
function lament.log.warn(msg, ...)
   return terminal.output.write(headers.warn .. " " .. msg, ...)
end

---comment
---@param msg any
---@param ... unknown
---@return unknown
function lament.log.info(msg, ...)
   return terminal.output.write(headers.info .. " " .. msg, ...)
end

---comment
---@param msg any
---@param ... unknown
---@return unknown
function lament.log.debug(msg, ...)
   return terminal.output.write(headers.info .. " " .. msg, ...)
end

return lament.log
