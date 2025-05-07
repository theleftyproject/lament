{
    description = "Simple bidirectional configuration system";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    inputs.asdf.url = "github:asdf-vm/asdf";
    imports.luajit = {
        url = "github:NixOS/nixpkgs/nixos-24.11";
        inputs = { self, nixpkgs };
    };

    outputs = { self, nixpkgs, asdf, luajit, ... }: let
        pkgs = import nixpkgs { system = builtins.currentSystem ; };
    in {
        packages.${builtins.currentSystem} = rec {
            lament = pkgs.stdenv.mkDerivation rec {
                pname = "lament";
                version = "dev-1";
                src = ./.;

                nativeBuildInputs = [
                    asdf,
                    just
                ];

                buildInputs = [

                ]
            }
        }
    }
}
