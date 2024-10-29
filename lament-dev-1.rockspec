package = "lament"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/Sparkles-Laurel/lament.git"
}
description = {
   homepage = "https://github.com/Sparkles-Laurel/lament",
   license = "MIT"
}
dependencies = {
   "lua >= 5.4",
   "lpeg == 1.1.0-2",
   "luafilesystem == scm1",
}
build = {
   type = "builtin",
   modules = {
      lament = "src/lament.lua",
      ["lament.hive"] = "src/lament/hive.lua",
      ["lament.key"] = "src/lament/key.lua",
      ["lament.loader"] = "src/lament/loader.lua"
   }
}
