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
   "lanes"
}
build_dependencies = {
   queries = {}
}
build = {
   type = "builtin",
   modules = {
      ["lament"] = "src/lament.lua",
      ["lament.util"] = "src/lament/util/util.lua",
      ["lament.util.enum"] = "src/lament/util/enum.lua",
      ["lament.util.switch"] = "src/lament/util/switch.lua",
      ["lament.cli"] = "src/lament/cli.lua"
   },
   copy_directories = {
      "docs"
   }
}
test_dependencies = {
   queries = {}
}
