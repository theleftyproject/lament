---@diagnostic disable: undefined-global

local SANDBOX_MODULE = "../src/exec/sandbox"

local original_preload_lament = package.preload["lament"]
local original_preload_lament_sandbox = package.preload["lament_sandbox"]

local temp_files = {}

local function write_temp_module(source)
   local path = os.tmpname()
   local file = assert(io.open(path, "w"))
   file:write(source)
   file:close()
   table.insert(temp_files, path)
   return path
end

local function load_sandbox(mock_rust_module)
   package.loaded[SANDBOX_MODULE] = nil
   package.loaded["lament"] = nil
   package.loaded["lament_sandbox"] = nil

   package.preload["lament"] = function()
      return {}
   end

   if mock_rust_module then
      package.preload["lament_sandbox"] = function()
         return mock_rust_module
      end
   else
      package.preload["lament_sandbox"] = function()
         error("mocked lament_sandbox missing")
      end
   end

   return require(SANDBOX_MODULE)
end

describe("Sandbox API", function()
   after_each(function()
      package.loaded[SANDBOX_MODULE] = nil
      package.loaded["lament"] = nil
      package.loaded["lament_sandbox"] = nil

      package.preload["lament"] = original_preload_lament
      package.preload["lament_sandbox"] = original_preload_lament_sandbox

      for _, path in ipairs(temp_files) do
         os.remove(path)
      end
      temp_files = {}
   end)

   it("falls back to legacy Lua backend when lament_sandbox is unavailable", function()
      local sandbox = load_sandbox(nil)
      local backend_path = write_temp_module([[
return {
  apply = function()
    return true
  end,
  recalibrate = function()
    return true
  end
}
]])

      local ok, err = sandbox.apply_module(backend_path)
      assert.is_true(ok)
      assert.is_nil(err)
   end)

   it("returns backend method errors from legacy Lua backend", function()
      local sandbox = load_sandbox(nil)
      local backend_path = write_temp_module([[
return {
  apply = function()
    return false, "apply failed"
  end
}
]])

      local ok, err = sandbox.apply_module(backend_path)
      assert.is_false(ok)
      assert.are.equal("apply failed", err)
   end)

   it("errors when legacy backend lacks requested function", function()
      local sandbox = load_sandbox(nil)
      local backend_path = write_temp_module([[
return {
  apply = function() end
}
]])

      local ok, err = sandbox.recalibrate_module(backend_path)
      assert.is_false(ok)
      assert.is_truthy(err:match("lacks a recalibrate field"))
   end)

   it("uses rust sandbox when available", function()
      local calls = {
         env_new = 0,
         registry_new = 0,
         load_paths = {},
         apply_calls = 0,
         recalibrate_calls = 0,
      }

      local rust_sandbox = {
         SandboxEnv = {
            new = function()
               calls.env_new = calls.env_new + 1
               return {}
            end
         },
         Registry = {
            new = function()
               calls.registry_new = calls.registry_new + 1
               return {}
            end
         },
         Sandbox = {
            new = function(_env, _registry)
               return {
                  load_script = function(self, module_path)
                     table.insert(calls.load_paths, module_path)
                  end,
                  call_apply = function(self)
                     calls.apply_calls = calls.apply_calls + 1
                     return true
                  end,
                  call_recalibrate = function(self)
                     calls.recalibrate_calls = calls.recalibrate_calls + 1
                     return true
                  end
               }
            end
         }
      }

      local sandbox = load_sandbox(rust_sandbox)
      local ok_apply = sandbox.apply_module("/definitely/missing.lua")
      local ok_recal = sandbox.recalibrate_module("/also/missing.lua")

      assert.is_true(ok_apply)
      assert.is_true(ok_recal)
      assert.are.equal(1, calls.env_new)
      assert.are.equal(1, calls.registry_new)
      assert.are.same({ "/definitely/missing.lua", "/also/missing.lua" }, calls.load_paths)
      assert.are.equal(1, calls.apply_calls)
      assert.are.equal(1, calls.recalibrate_calls)
   end)

   it("falls back to legacy when rust sandbox call fails", function()
      local rust_sandbox = {
         SandboxEnv = { new = function() return {} end },
         Registry = { new = function() return {} end },
         Sandbox = {
            new = function(_env, _registry)
               return {
                  load_script = function(self, module_path)
                     error("rust load failed")
                  end,
                  call_apply = function(self) end,
                  call_recalibrate = function(self) end
               }
            end
         }
      }

      local sandbox = load_sandbox(rust_sandbox)
      local backend_path = write_temp_module([[
return {
  apply = function()
    return true
  end
}
]])

      local ok, err = sandbox.apply_module(backend_path)
      assert.is_true(ok)
      assert.is_nil(err)
   end)
end)
