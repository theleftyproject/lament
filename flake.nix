## flake.nix - build automation for Nix
##    Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
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

{
    description = "Simple bidirectional configuration system";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    inputs.flake-utils.url = "github:numtide/flake-utils";
    inputs.flake-utils.inputs.systems.follows = "systems";
    inputs.asdf.url = "github:asdf-vm/asdf";

    imports.luajit = {
        url = "github:NixOS/nixpkgs/nixos-24.11";
        inputs = { self, nixpkgs };
    };

    outputs = { self, nixpkgs, asdf, luajit, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };

                lua = pkgs.luajit;
                luarocks = pkgs.luarocks.override { inherit lua ;};
            in {
                devShells.default = pkgs.mkShell {
                    name = "luajit-dev-env";

                    nativeBuildInputs = [
                        pkgs.just
                        lua
                        luarocks
                    ];
                };

                packages.default = pkgs.runCommand "build-with-just" {
                    buildInputs = [ pkgs.just ];
                } ''
                    just build
                    touch $out
                ''
            }
        );
}
