-- cli.lua - The LAMENT command-line tool
--
--     Copyright (C) 2024  Kıvılcım Defne Öztürk
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

local parser = argparse("lament", "The gayest configuration tool")

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
    print("Usage:")
    print("  lament <command> [options]")
    print()
    print("Commands:")
    print("  set <module> <setting> <value>                   Set a value for a module setting")
    print("  advanced <module> <setting> <action> <value>    Advanced setting operations (append, remove, set)")
    print("  apply                                           Apply all changes")
    print()
    print("Options:")
    print("  --module <module>       The module name")
    print("  --setting <setting>     The setting name")
    print("  --value <value>         The value to set or append")
    print("  --action <action>       The action to perform (append, remove, set)")
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
            print(string.format("Appending '%s' to setting '%s' of module '%s'.", args.value, args.setting, args.module))
        elseif args.action == "remove" then
            print(string.format("Removing '%s' from setting '%s' of module '%s'.", args.value, args.setting, args.module))
        elseif args.action == "set" then
            print(string.format("Setting '%s' of module '%s' to '%s'.", args.setting, args.module, args.value))
        else
            print("Unknown action. Use 'append', 'remove', or 'set'.")
            print_help()
        end
    else
        print("Missing arguments for 'advanced' command.")
        print_help()
    end
end
