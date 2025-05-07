## Justfile - for build orchestration
##     Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
set unstable

_cc := require("clang")
_cxx := require("clang++")
asdf := require("asdf")
lua := require("lua")
luac := require("luac")
luarocks := require("luarocks")
podman := require("podman")
lualatex := which("lualatex")
luacheck := require("luacheck")
busted := require("busted")

[group("util")]
setup-env:
    {{asdf}} set lua 5.1
    {{asdf}} reshim
    {{luarocks}} install lanes
[group("test")]
lint:
    {{luarocks}} lint lament-*.rockspec
    {{luacheck}} src/*
test:
    {{busted}} -o TAP

[group("build")]
build: setup-env test
    {{luarocks}} build
