---@diagnostic disable: undefined-field
local lament = require("lament")
lament.sandbox = {}

local ok_rust, lament_sandbox = pcall(require, "lament_sandbox")
local rust_env
local rust_registry

-- the environment that is not being masqueraded
-- TODO: masquerade a controlled environment
local env = {
    math = math, string = string, table = table,
    lpeg = require("lpeg"),
    http = require("socket.http"),
    io = { open = io.open, read = io.read, write = io.write },
    os = { time = os.time, date = os.date, difftime = os.difftime, execute = os.execute }
}

-- The masqueradae environment
local masq_env = {}

-- Functions that do not need authorization
masq_env.math = env.math
masq_env.string = env.string
masq_env.table = env.table
masq_env.lpeg = env.lpeg
-- Functions that do need authorization
-- TODO: Implement authorization and logging for these functions
masq_env.http = {}
masq_env.io = {}
masq_env.os = {}

local function load_module(module_path)
   local chunk, err = loadfile(module_path, "t", masq_env)
   if not chunk then
      return nil, err
   end
   return chunk()
end

local function normalize_call_result(values)
   if #values == 0 or values[1] == nil then
      return true
   end

   if type(values[1]) == "boolean" then
      return values[1], values[2]
   end

   return true, values[1]
end

local function get_rust_sandbox()
   if not ok_rust then
      return nil, "lament_sandbox is not available"
   end

   if not rust_env then
      rust_env = lament_sandbox.SandboxEnv.new()
   end
   if not rust_registry then
      rust_registry = lament_sandbox.Registry.new()
   end

   return lament_sandbox.Sandbox.new(rust_env, rust_registry)
end

local function invoke_rust(module_path, method)
   local sandbox, err = get_rust_sandbox()
   if not sandbox then
      return false, err
   end

   local ok, load_err = pcall(function()
      sandbox:load_script(module_path)
   end)
   if not ok then
      return false, tostring(load_err)
   end

   ok, load_err = pcall(function()
      if method == "apply" then
         return { sandbox:call_apply() }
      else
         return { sandbox:call_recalibrate() }
      end
   end)
   if not ok then
      return false, tostring(load_err)
   end

   return normalize_call_result(load_err)
end

local function invoke_legacy(module_path, method)
   local mod, err = load_module(module_path)
   if not mod then
      return false, err
   end

   if mod and mod[method] then
      local ok, result = pcall(function()
         return { mod[method](mod) }
      end)
      if ok then
         return normalize_call_result(result)
      end
      return false, tostring(result)
   end

   return false, "this backend lacks a " .. method .. " field"
end

function lament.sandbox.apply_module(module_path)
   local ok, err = invoke_rust(module_path, "apply")
   if ok then
      return true
   end
   return invoke_legacy(module_path, "apply")
end

function lament.sandbox.recalibrate_module(module_path)
   local ok, err = invoke_rust(module_path, "recalibrate")
   if ok then
      return true
   end
   return invoke_legacy(module_path, "recalibrate")
end
