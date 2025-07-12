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
describe("dummy test for environment", function()
   it("should not fail at all", function()
       assert.is.truthy("Estaya labylonse")
       assert.is.truthy(true)
       assert.is.truthy(1)
       assert.is.truthy({{}})
   end)
   it("should be able to compare", function()
      assert.are.same({ table = "great"}, { table = "great" })
   end)
   it("should be able to react to falsy values", function ()
      assert.is.falsy(nil)
      assert.is.falsy(false)
   end)
end)
