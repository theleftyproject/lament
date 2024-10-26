-- hive.lua - defines LAMENT configuration hives

local lament = require('lament')

-- defines a hive
local Hive = {}

-- instantiates a new Hive
function Hive.new(name, default_keys)
   return setmetatable({
      name = name,
      keys = default_keys
   }, {__index = Hive})
end

-- reads a hive key
function Hive:get_key(key)
   -- if the key exists, return its value
   if self[key] ~= nil then
      return self[key]
   end

   -- else return null
   return nil
end

-- sets a hive key
function Hive:set_key(key, value)
   self[key] = value
   return self
end
