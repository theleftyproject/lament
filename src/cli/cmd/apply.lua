local lament = require("lament")
local engine = require("engine")
local log = require("log")
require("engine.apply")

local function apply(parsed)
   log.info("Starting configuration application...")
   local result = engine.apply()
   if result then
      log.info("Application successful.")
      return 0
   else
      log.error("Application failed.")
      return 1
   end
end

return apply
