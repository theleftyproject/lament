#!/bin/env sh
## test/install-lexpect.sh - lexpect installation script for containers.
##     Copyright (C) 2024-2025  Kıvılcım İpek Defne Öztürk
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

if [[ ! -e /.dockerenv ]] || [[ ! -e /.containerenv ]]; then
    echo "[ERROR] This script is for installing into containers"
    exit 31
fi

if ! which cargo; then
    echo "[ERROR] Malfunctioning environment (no cargo)"
    exit 31
fi

# may be useful in future

if [[ -e /.dockerenv ]]; then
    export LEFTY_IN_DOCKER=1
    export LEFTY_IN_CONTAINER=1
    export LEFTY_CONTAINER_RT="docker"
elif [[ -e /.containerenv ]]; then
    export LEFTY_IN_PODMAN=1
    export LEFTY_IN_CONTAINER=1
    export LEFTY_CONTAINER_RT="oci"
fi

exec cargo install lexpect --git https://codeberg.org/KanakoTheGay/lexpect.git
