local lament = require("lament")
local log = require("log")
local resolve = require("cli.resolve")
local const = require("lament.const")

local function get_hive_from_registry(hive_name)
   if const.globals._REGISTRY then
       local hive = const.globals._REGISTRY:get_hive(hive_name)
       if hive then return hive end
   end
   for i = 1, #const.globals._MODULES do
       local module = const.globals._MODULES[i]
       if module.hives and module.hives[hive_name] then
           return module.hives[hive_name]
       end
   end
   return nil
end

local function get(parsed)
   local key_path = resolve.resolve_key(parsed.key)
   if not key_path or #key_path < 2 then
      log.error("Invalid key format. Expected hive_name.key_name. Got: " .. tostring(parsed.key))
      return 1
   end

   local hive_name = key_path[1]
   local target_hive = get_hive_from_registry(hive_name)

   if not target_hive then
      log.error("Hive not found: " .. tostring(hive_name))
      return 1
   end

   local current = target_hive
   for i = 2, #key_path do
      local segment = key_path[i]
      if type(current) ~= "table" and type(current) ~= "userdata" then
         log.error("Key path not found in hive.")
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
