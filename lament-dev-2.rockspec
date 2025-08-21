package = "lament"
version = "dev-2"
source = {
   url = "git+https://github.com/Sparkles-Laurel/lament.git"
}
description = {
   detailed = "**L**efty **A**pplication, **M**odification, **E**diting and **N**otification **T**ool",
   homepage = "https://github.com/Sparkles-Laurel/lament",
   license = "GPLv3"
}
dependencies = {
   "penlight",
   "luafilesystem",
   "lpeg",
   "argparse",
   "lanes",
   "sandbox",
   "luasocket"
}
build = {
   type = "builtin",
   modules = {
      ["lament"] = "src/lament.lua",
      ["lament.util"] = "src/util/util.lua",
      ["lament.util.enum"] = "src/util/enum.lua",
      ["lament.util.switch"] = "src/util/switch.lua",
      ["lament.cli"] = "src/cli/cli.lua",
      ["lament.hive"] = "src/hive/hive.lua",
      ["lament.hive.key"] = "src/hive/key.lua",
      ["lament.interface.backend"] = "src/interface/backend.lua",
      ["lament.interface.registry"] = "src/interface/registry.lua"
   },
   copy_directories = {
      "docs"
   },
   bin = {
      ["lament"] = "src/cli/lament"
   }
}
