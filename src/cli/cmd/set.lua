local lament = require("lament")
local log = require("log")
local resolve_key = require("cli.resolve").resolve_key
local const = require("lament.const")

local function set(parsed)
   local key_path = resolve_key(parsed.key)
   if not key_path then
      log.error("Invalid key format: " .. tostring(parsed.key))
      return 1
   end

   local current = const.globals._SYSCONF
   for i = 1, #key_path - 1 do
      local segment = key_path[i]
      if type(current) ~= "table" and type(current) ~= "userdata" then
         log.error("Key path not found in configuration.")
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
      log.info("Cleared key: " .. parsed.key)
   elseif parsed.append then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      table.insert(current[last_seg], parsed.append)
      log.info("Appended to " .. parsed.key)
   elseif parsed.prepend then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      table.insert(current[last_seg], 1, parsed.prepend)
      log.info("Prepended to " .. parsed.key)
   elseif parsed.set_index then
      if type(current[last_seg]) ~= "table" then current[last_seg] = {} end
      current[last_seg][tonumber(parsed.set_index[1])] = parsed.set_index[2]
      log.info("Set index on " .. parsed.key)
   elseif parsed.nil_index then
      if type(current[last_seg]) == "table" then
         current[last_seg][tonumber(parsed.nil_index)] = nil
         log.info("Nil index " .. parsed.key)
      end
   elseif parsed.del_index then
      if type(current[last_seg]) == "table" then
         table.remove(current[last_seg], tonumber(parsed.del_index))
         log.info("Deleted index " .. parsed.key)
      end
   else
      current[last_seg] = value
      log.info("Set key: " .. parsed.key .. " to " .. tostring(value))
   end

   return 0
end

return set
