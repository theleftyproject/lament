---@diagnostic disable: undefined-global

local Hive = require("../src/hive/hive").Hive
local Key = require("../src/hive/key").Key
local Registry = require("../src/interface/registry").Registry
local Backend = require("../src/interface/backend").Backend

describe("LAMENT API", function()
   it("applies key defaults and validated writes through hive accessors", function()
      local hive = Hive("editor")
      local key = Key("tab_size", {
         default = 4,
         validate = function(value)
            return type(value) == "number" and value > 0
         end
      })

      hive:register_key(key)

      assert.are.equal(4, hive.tab_size)

      hive.tab_size = 2
      assert.are.equal(2, hive.tab_size)

      assert.has_error(function()
         hive.tab_size = -1
      end, "Validation failed for key: tab_size")
   end)

   it("stores and resolves hives through registry", function()
      local registry = Registry()
      local hive = Hive("fonts")

      registry:register_hive("fonts", hive)

      assert.are.equal(hive, registry:get_hive("fonts"))
      assert.is_nil(registry:get_hive("missing"))
   end)

   it("executes backend lifecycle transitions", function()
      local backend = Backend("/tmp/backend.lua")

      local pre_calls = 0
      local post_calls = 0
      backend.pre_init = function(self)
         pre_calls = pre_calls + 1
         return nil
      end
      backend.post_init = function(self)
         post_calls = post_calls + 1
         return nil
      end

      assert.is_nil(backend:init())
      assert.is_true(backend.active)
      assert.are.equal(1, pre_calls)
      assert.are.equal(1, post_calls)

      assert.is_nil(backend:quit())
      assert.is_false(backend.active)
   end)

   it("short-circuits backend apply/recalibrate on event errors", function()
      local backend = Backend("/tmp/backend.lua")
      backend.active = true

      backend.pre_apply = function(self)
         return "pre-apply-failed"
      end
      backend.applying = function(self)
         return "should-not-run"
      end

      assert.are.equal("pre-apply-failed", backend:apply())

      backend.pre_recalibrate = function(self)
         return nil
      end
      backend.recalibrating = function(self)
         return "run-failed"
      end
      backend.post_recalibrate = function(self)
         return "post-ignored"
      end

      assert.are.equal("run-failed", backend:recalibrate())
   end)
end)
