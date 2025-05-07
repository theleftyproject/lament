#!/bin/sh
# lefty-escal - figure out how to elevate permissions in an environment, prioritizing policykit
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

set -euxo pipefail

# escalators, with priority order
LEFTY_ESCALATORS=(run0 pkexec doas sudo su)
LEFTY_ESCAL_PICK=""
for i in $LEFTY_ESCALATORS; do
    if `which $i`; then
        LEFTY_ESCAL_PICK="${i}" break
    fi
done

