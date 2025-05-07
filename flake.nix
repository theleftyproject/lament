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
