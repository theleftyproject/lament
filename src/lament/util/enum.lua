local lament = require('lament')

--- Enums and discriminated unions
lament.util.enum = {}

local function inner(key)
   return function(data)
      local tbl = {
         key = key
      }

      if type(data) == 'table' then
         for i, v in pairs(data) do
            tbl[i] = v
         end
      else
         tbl.inner = data
      end

      return setmetatable(tbl, { __call = function() return data end })
   end
end

---Instantiates a new [lament.util.enum.Enum]
---@param ... unknown List of keys in the enum
---@return table Enum The enum table
function lament.util.enum.Enum(...)
   local tbl = {}

   for i = 1, select('#', ...) do
      local key = select(i, ...)

      tbl[key] = inner(key)
   end

   return tbl
end

return lament.util.enum
