local args = {...}

local function print_usage()
    print("Usage:")
    print("  lament <module> <setting> <value>")
    print("  lament <module> <setting[]> --append|--remove|--set <value>")
    print("  lament -A|--apply")
end

local function handle_set(module, setting, value)
    print(string.format("Setting '%s' of module '%s' to '%s'.", setting, module, value))
end

local function handle_advanced(module, setting, action, value)
    if action == '--append' then
        print(string.format("Appending '%s' to setting '%s' of module '%s'.", value, setting, module))
    elseif action == '--remove' then
        print(string.format("Removing '%s' from setting '%s' of module '%s'.", value, setting, module))
    elseif action == '--set' then
        print(string.format("Setting '%s' of module '%s' to '%s'.", setting, module, value))
    else
        print("Unknown action. Use --append, --remove, or --set.")
    end
end

local function handle_apply()
    print("Applying all changes...")
end

local command = args[1]

if command == "-A" or command == "--apply" then
    handle_apply()
elseif #args == 3 then
    local module, setting, value = args[1], args[2], args[3]
    handle_set(module, setting, value)
elseif #args >= 4 then
    local module, setting, action = args[1], args[2], args[3]
    local value = args[4]

    if action == '--append' or action == '--remove' or action == '--set' then
        handle_advanced(module, setting, action, value)
    else
        print_usage()
    end
else
    print_usage()
end
