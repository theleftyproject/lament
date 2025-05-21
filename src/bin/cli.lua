-- cli.lua - The LAMENT command-line tool
--
--     Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
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

-- TODO: fix this shit

local argparse = require("argparse")

local parser = argparse("lament", "Apply or recalibrate LAMENT rules")

local set_cmd = parser:command("set", "Set a value for a module setting")
set_cmd:argument("module", "The module name")
set_cmd:argument("setting", "The setting name")
set_cmd:argument("value", "The value to set")

local advanced_cmd = parser:command("advanced", "Advanced setting operations")
advanced_cmd:argument("module", "The module name")
advanced_cmd:argument("setting", "The setting name")
advanced_cmd:argument("action", "The action to perform (append, remove, set)")
advanced_cmd:argument("value", "The value to append or set")

parser:command("apply", "Apply all changes")

local args = parser:parse()

local function print_help()
   print("lament - Alters or reads configuration files based on instructions.")
   print("Usage:")
   print("  lament <key> <action> [options]")
   print("  lament --apply [options]")
   print("  lament --recalibrate [options]")
   print("  lament --cross-calibrate [options]")
   print("  lament --help")
   print()
   print("Arguments:")
   print("  <key>                            Key for configuration elements.")
   print("  <action>                         Either get or set, what to do with the key")
   print()
   print("Global Options:")
   print("  --apply                          Forwards apply the changes to the system's configuration")
   print("  --recalibrate                    Backwards apply the changes in configuration to LAMENT's own configuration")
   print("  --cross-calibrate                [VERY EXPERIMENTAL] Perform application or recalibration based on which side is newer")
   print()
   print("Options for lament <key> set:")
   print("  <value>                          Used for most keys. Dictates the value of the key to be set.")
   print("  --clear                          Clear the value of optional keys. Will error if used with compulsory keys.")
   print("  --append, -a <value>             Only used for list keys. Add a value to the end of the list on the key")
   print("                                   <value>: The value to append.")
   print("  --prepend, -p <value>            Only used for list keys. Add a value to the beginning of the list on the key.")
   print("                                   <value>: The value to prepend.")
   print("  --set-index, -s <index> <value>  Only used for list keys. Amend a single index of the keys.")
   print("                                   Cannot be used to amend dictionaries. Dictionaries must be amended with the object path resolution.")
   print("                                   <index>: Must be a positive natural number. The index of the list to amend.")
   print("                                   <value>: The value at the index to amend")
   print("  --nil-index, -n <index>          Only used for list keys. Set the value of <index> to nil.")
   print("                                   This is different from --del-index which deletes the member of the array at the said index.")
   print("  --del-index, -d <index>          Only used for list keys. Delete the index from the sequence. Cannot be used with dictionaries.")
   print("                                   After this operation the length of the value reduces by one.")
   print("                                   <index>: Must be a positive natural number. The index to delete.")
   print()
   print("Options for lament <key> get:")
   print("  --index, --at, -i <index>        Only used for list keys. Get the value on the specified index.")
   print("                                   <index>: Must be a postive natural number. The index to get the value of.")
end

if args._command == "apply" then
    print("Applying all changes...")
elseif args._command == "set" then
    if args.module and args.setting and args.value then
        print(string.format("Setting '%s' of module '%s' to '%s'.", args.setting, args.module, args.value))
    else
        print("Missing arguments for 'set' command.")
        print_help()
    end
elseif args._command == "advanced" then
    if args.module and args.setting and args.action and args.value then
        if args.action == "append" then
            print(string.format("Appending '%s' to setting '%s' of module '%s'.",
            args.value, args.setting, args.module))
        elseif args.action == "remove" then
            print(string.format("Removing '%s' from setting '%s' of module '%s'.",
            args.value, args.setting, args.module))
        elseif args.action == "set" then
            print(string.format("Setting '%s' of module '%s' to '%s'.",
            args.setting, args.module, args.value))
        else
            print("Unknown action. Use 'append', 'remove', or 'set'.")
            print_help()
        end
    else
        print("Missing arguments for 'advanced' command.")
        print_help()
    end
end
