#!/usr/bin/nu
## git-com.nu - git-com configuration file execution script.
##    Copyright (C) 2026  Kıvılcım İpek Afet Öztürk
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

# if jsonnet is absent, stop.
if (which jsonnet) == [] {
    error make {
        msg: "failed to find jsonnet",
        code: "lefty::build_infra::cmd_not_found::jsonnet",
        labels: [{
            text: "this command depends on the presence of jsonnet"
        }],
        help: "try installing jsonnet",
        url: "https://jsonnet.org/"
    }
    exit 1
}

# Manifest a yaml document from the jsonnet spec
let yaml_doc: string  = ^jsonnet .git-com.jsonnet | from json

# Print the git-com configuration into the spec
echo $yaml_doc out> .git-com.yml

