-- src/cli/cli.lua - the command line interface
--
--     Copyright (C) 2024-2025  Kıvılcım İpek Defne Öztürk
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


local argparse = require("argparse")
-- TODO: Do make use of resolve
-- local resolve = require("resolve")

local function main(args)
  local parser = argparse("lament",
         "Alters or reads configuration files based on instructions.")

  -- Global flags
  parser:flag("--apply -A",
      "Forwards apply the changes to the system's configuration")
  parser:flag("--recalibrate --reconcile -B",
      "Backwards apply the changes in configuration to LAMENT's own configuration")
  parser:flag("--cross-calibrate -C",
      "[VERY EXPERIMENTAL] Perform application or recalibration based on which side is newer")
  parser:flag("--help -h", "Show help")

  -- Positional arguments for <key> and <action>
  parser:argument("key")
        :args("?")
        :description("Key for configuration elements.")
  parser:argument("action")
        :args("?")
        :description("Either get or set, what to do with the key")

  -- Options for 'set'
  parser:option("--append -a")
         :args(1)
         :description("Only used for list keys. Add a value to the end of the list on the key")
  parser:option("--prepend -p")
         :args(1)
         :description("Only used for list keys. Add a value to the beginning of the list on the key")
  parser:option("--set-index -s")
         :args(2)
         :description("Only used for list keys. Amend a single index of the keys")
  parser:option("--nil-index -n")
         :args(1)
         :description("Only used for list keys. Set the value of <index> to nil")
  parser:option("--del-index -d")
         :args(1)
         :description("Only used for list keys. Delete the index from the sequence")
  parser:flag("--clear -c",
         "Clear the value of optional keys. Will error if used with compulsory keys")

  -- Option for 'get'
  parser:option("--index --at -i")
        :args(1)
        :description("Only used for list keys. Get the value on the specified index")

  local parsed = parser:parse(args)

   if parsed.help then
      print(parser:get_help())
      return 0
   end

   if parsed.apply then
      print("[DUMMY] Applying changes to system configuration")
      return 0
   elseif parsed.recalibrate then
      print("[DUMMY] Backwards applying changes to LAMENT's own configuration")
      return 0
   elseif parsed.cross_calibrate then
      print("[DUMMY] Performing cross-calibration (experimental)")
      return 0
   end

   if parsed.key and parsed.action then
      if parsed.action == "get" then
      print("[DUMMY] Getting key:", parsed.key)
      if parsed.index then
        print("[DUMMY] Getting index:", parsed.index)
      end
      return 0
   elseif parsed.action == "set" then
      local value = parsed[1] or "<no value>"
      print("[DUMMY] Setting key:", parsed.key, "with value:", value)
      if parsed.clear then
         print("[DUMMY] Clearing key value")
      end
      if parsed.append then
         print("[DUMMY] Appending:", parsed.append)
      elseif parsed.prepend then
         print("[DUMMY] Prepending:", parsed.prepend)
      elseif parsed.set_index then
         print("[DUMMY] Setting index:", parsed.set_index[1], "to", parsed.set_index[2])
      elseif parsed.nil_index then
         print("[DUMMY] Setting index:", parsed.nil_index, "to nil")
      elseif parsed.del_index then
         print("[DUMMY] Deleting index:", parsed.del_index)
      end
      return 0
    else
      print("Error: <action> must be either 'get' or 'set'")
      return 1
    end
   else
      print("Error: Missing <key> and/or <action> arguments")
      print(parser:get_help())
      return 1
   end
end

return {
   main = main
}
