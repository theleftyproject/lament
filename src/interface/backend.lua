-- src/interface/backend.lua - backends for configuration
--
--     Copyright (C) 2024 - 2026  Kıvılcım İpek Afet Öztürk
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

local class = require("pl.class")

--- Represents a configuration backend
local Backend = class()

--- Pick the first errorneous one from pre-run, run and post-run
local function pre_post_pick(pre, run, post)
   if pre != nil then
      return pre
   elseif run != nil then
      return run
   elseif post != nil then
      return post
   end

   return nil
end

function Backend:_init(path)
   --- Name of the backend
   self.name = "backend"
   --- Path of the backend
   self.path = path
   --- Hives the backend registers
   self.hives = {}
   --- Files the backend accesses
   self.open_files = {}
   --- Whether the backend is enabled
   self.active = false
   --- Event handler for pre_init event
   self.pre_init = function (self) end
   --- Event handler for post_init event
   self.post_init = function (self) end
   --- Event handler for pre_quit event
   self.pre_quit = function (self) end
   --- Event handler for post_quit event
   self.post_quit = function (self) end
   --- Event handler for pre_apply event
   self.pre_apply = function (self) end
   --- Event handler for post_apply event
   self.post_apply = function (self) end
   --- Event handler for pre_recalibrate event
   self.pre_recalibrate = function (self) end
   --- Event handler for post_recalibrate event
   self.post_recalibrate = function (self) end
   --- Event handler for applying event
   self.applying = function (self) end
   --- Event handler for recalibrating event
   self.recalibrating = function (self) end
end

function Backend:init()
   pre_err = self:pre_init()
   if pre_err != nil then
      return pre_err
   end

   self.active = true

   post_err = self:post_init()
   if post_err != nil then
      self.active = false
      return post_err
   end

   return nil
end

function Backend:quit()
   pre_err = self:pre_quit()
   if pre_err != nil then
      return pre_err
   end

   self.active = false

   post_err = self:post_quit()
   if post_err != nil then
      self.active = true
      return post_err
   end

   return nil
end

function Backend:apply()
   if not self.active then
      return nil
   end
   return pre_post_pick(self:pre_apply(), self:applying(), self:post_apply())
end

function Backend:recalibrate()
   if not self.active then
      return nil
   end
   return pre_post_pick(self:pre_recalibrate(), self:recalibrating(), self:post_recalibrate())
end

return {
   Backend = Backend,
}
