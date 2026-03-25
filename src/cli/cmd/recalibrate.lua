local lament = require("lament")
local engine = require("engine")
local log = require("log")
require("engine.recalibrate")

local function recalibrate(parsed)
   log.info("Starting configuration recalibration...")
   local result = engine.recalibrate()
   if result then
      log.info("Recalibration successful.")
      return 0
   else
      log.error("Recalibration failed.")
      return 1
   end
end

return recalibrate
