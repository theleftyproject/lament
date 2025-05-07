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

CC := require("clang")
CXX := require("clang++")
ASDF := require("asdf")
LUA := require("lua5.1")
LUAROCKS := require("luarocks")
LUAJIT := which("luajit")
LUALATEX := which("lualatex")
DOCKER := which("docker") || require("podman")

[group('build')]
[linux]
build:
#   TODO: add nix detection
    {{LUAROCKS}} build

[windows]
build:
    error("lament only supports linux hosts, consider using cross-build")
