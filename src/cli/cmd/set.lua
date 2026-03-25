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

local function set(parsed)
   local key_path = resolve.resolve_key(parsed.key)
   if not key_path or #key_path < 2 then
      log.error("Invalid key format. Expected hive_name.key_name. Got: " .. tostring(parsed.key))
      return 1
   end

   local hive_name = key_path[1]
   local hive = get_hive_from_registry(hive_name)

   if not hive then
      log.error("Hive not found: " .. tostring(hive_name))
      return 1
   end

   local current = hive
   for i = 2, #key_path - 1 do
      local segment = key_path[i]
      if type(current) ~= "table" and type(current) ~= "userdata" then
         log.error("Key path not found in hive.")
         return 1
      end
      if not current[segment] then
         current[segment] = {}
      end
      current = current[segment]
   end

   local last_seg = key_path[#key_path]
   local value = parsed[1]

   if parsed.clear then
      current[last_seg] = nil
      log.info("Cleared key: " .. tostring(parsed.key))
   elseif parsed.append then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      table.insert(current[last_seg], parsed.append)
      log.info("Appended to " .. tostring(parsed.key))
   elseif parsed.prepend then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      table.insert(current[last_seg], 1, parsed.prepend)
      log.info("Prepended to " .. tostring(parsed.key))
   elseif parsed.set_index then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      current[last_seg][tonumber(parsed.set_index[1])] = parsed.set_index[2]
      log.info("Set index on " .. tostring(parsed.key))
   elseif parsed.nil_index then
      if type(current[last_seg]) == "table" then
         current[last_seg][tonumber(parsed.nil_index)] = nil
         log.info("Nil index " .. tostring(parsed.key))
      end
   elseif parsed.del_index then
      if type(current[last_seg]) == "table" then
         table.remove(current[last_seg], tonumber(parsed.del_index))
         log.info("Deleted index " .. tostring(parsed.key))
      end
   else
      current[last_seg] = value
      log.info("Set key: " .. tostring(parsed.key) .. " to " .. tostring(value))
   end

   return 0
end

return set
