---@diagnostic disable: undefined-field
-- check_busted.lua - basic test that demonstrates whether the implementation of busted that is present is bugged
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

---@diagnostic-disable undefined-global

-- Import the key resolver
local lament = {
---@diagnostic disable-next-line: different-requires
   key_resolver = require("../src/cli/resolve")
}

-- Test cases for key resolver
describe("Key resolver unit tests", function()
   it("should resolve a string key without spaces,"
      .. " underscores or hyphens", function()
      local resolution = lament.key_resolver.resolve_key("foo.bar.baz")
      assert.are.same({"foo", "bar", "baz"}, resolution)
   end)
   it("should resolve a string key without spaces "
      .. "but with underscores", function()
         local resolution = lament.key_resolver.resolve_key("foo.bar_baz")
         assert.are.same({"foo", "bar_baz"}, resolution)
   end)
   it("should resolve a string key with spaces but"
      .. " without underscores", function()
         local resolution = lament.key_resolver.resolve_key('foo.["bar baz"]')
         assert.are.same({"foo", '["bar baz"]'}, resolution)
   end)
   it("should resolve a string key with "
      .. "hyphens but no spaces or underscores", function()
         local resolution = lament.key_resolver.resolve_key('foo.bar-baz')
         assert.are.same({"foo", "bar-baz"}, resolution)
   end)
   it("should resolve a string key with "
      .. "hyphens and underscores but no spaces", function()
         local resolution = lament.key_resolver.resolve_key("foo.bar-baz.quux_squeak")
         assert.are.same({"foo", "bar-baz", "quux_squeak"}, resolution)
   end)
   it("should resolve a string key with "
      .. "hyphens, underscores and spaces", function()
         local resolution = lament.key_resolver.resolve_key('foo.bar-baz.["quux squeak"].gay')
         assert.are.same({"foo", "bar-baz", '["quux squeak"]', 'gay'}, resolution)
   end)
   it("should resolve an alphanumeric key", function()
      local resolution = lament.key_resolver.resolve_key('foo.bar.0')
      assert.are.same({"foo", "bar", 0}, resolution)
   end)
end)
