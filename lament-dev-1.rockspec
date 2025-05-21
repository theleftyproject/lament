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
   "lua >= 5.1",
   "lpeg == 1.1.0-2",
   "luafilesystem == 1.8.0-1",
   "penlight == 1.14.0-3"
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
