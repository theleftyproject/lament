local lament = require("lament")
local log = require("log")
---@diagnostic disable-next-line: different-requires
local resolve_key = require("cli.resolve").resolve_key
local const = require("lament.const")

local function get(parsed)
   local key_path = resolve_key(parsed.key)
   if not key_path then
      log.error("Invalid key format: " .. tostring(parsed.key))
      return 1
   end

   local current = const.globals._SYSCONF
   for _, segment in ipairs(key_path) do
      if type(current) ~= "table" and type(current) ~= "userdata" then
         log.error("Key path not found in configuration.")
         return 1
      end
      current = current[segment]
   end

   if parsed.index then
      if (type(current) == "table" or type(current) == "userdata") and current[tonumber(parsed.index)] ~= nil then
         print(tostring(current[tonumber(parsed.index)]))
      else
         log.error("Index not found or value is not a list.")
         return 1
      end
   else
      print(tostring(current))
   end

   return 0
end

return get
