-- check_busted.lua - basic test that demonstrates whether the implementation of busted that is present is bugged
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
---@diagnostic disable undefined-global

local key_resolver = require("hive.key_resolver")

describe("key_resolver.parse_key_path", function()
   it("parses simple dot-separated identifiers", function()
      local path = "hive.foo.bar"
      local keys = key_resolver.parse_key_path(path)
      assert.are.same({ "hive", "foo", "bar" }, keys)
   end)

   it("parses numeric keys", function()
      local path = "hive.items.0.1"
      local keys = key_resolver.parse_key_path(path)
      assert.are.same({ "hive", "items", 0, 1 }, keys)
   end)

   it("parses numeric keys inside brackets", function()
      local path = 'hive.items.[0].[1]'
      local keys = key_resolver.parse_key_path(path)
      assert.are.same({"hive", "items", "0", "1"}, keys)
   end)

   it("parses quoted keys inside brackets", function()
      local path = 'hive.["complex.key"].other'
      local keys = key_resolver.parse_key_path(path)
      assert.are.same({ "hive", "complex.key", "other" }, keys)
   end)

   it("errors on unclosed quote", function()
      local path = 'hive.["oops'
      assert.has_error(function()
         key_resolver.parse_key_path(path)
      end, "Unclosed quote in key path")
   end)

   it("errors on invalid key after dot", function()
      local path = "hive."
      assert.has_error(function()
         key_resolver.parse_key_path(path)
      end)
   end)
end)
