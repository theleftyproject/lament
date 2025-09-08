-- src/hive/key_resolver.lua - Parses LAMENT key strings and resolves them
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

-- local lament = require("lament")

---Resolves a key path
---@param path string The path to the key
---@return table kpath resolved path to access the key
local function parse_key_path(path)
    local keys = {}
    local i = 1
    local len = #path

    local function peek() return path:sub(i,i) end
    local function next_char()
        local c = path:sub(i,i)
        i = i + 1
        return c
    end

    local function parse_identifier()
        local start = i
        while i <= len and path:sub(i,i):match("[%a_][%w_]*") do
            i = i + 1
        end
        if start == i then return nil end
        return path:sub(start, i-1)
    end

    local function parse_number()
        local start = i
        while i <= len and path:sub(i,i):match("%d") do
            i = i + 1
        end
        if start == i then return nil end
        return tonumber(path:sub(start, i-1))
    end

    local function parse_quoted()
        if peek() ~= '"' then return nil end
        next_char() -- skip opening "
        local start = i
        while i <= len and peek() ~= '"' do
            i = i + 1
        end
        if i > len then error("Unclosed quote in key path") end
        local value = path:sub(start, i-1)
        next_char() -- skip closing "
        return value
    end

    -- parse hive
    local hive = parse_identifier()
    if not hive then error("Invalid hive at start") end
    table.insert(keys, hive)

    while i <= len do
        local c = next_char()
        if c ~= '.' then error("Expected '.' between keys") end

        local key
        if peek() == '[' then
            -- dot followed by bracketed string
            next_char() -- skip '['
            if peek() ~= '"' then error("Expected quoted key inside brackets") end
            key = parse_quoted()
            if next_char() ~= ']' then error("Expected closing ']'") end
        else
            key = parse_identifier() or parse_number()
            if not key then
                error("Invalid key after '.' at position "..i)
            end
        end
        table.insert(keys, key)
    end

    return keys
end

return { parse_key_path = parse_key_path }
