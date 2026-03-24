local lament = require("lament")
local engine = require("engine")
local log = require("log")

local function cross_calibrate(parsed)
   log.info("Starting cross-calibration (experimental)...")
   local result = engine.cross_calibrate()
   if result then
      log.info("Cross-calibration successful.")
      return 0
   else
      log.error("Cross-calibration failed.")
      return 1
   end
end

return cross_calibrate
