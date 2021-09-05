{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ kicad-unstable-small gerbv python3 ];
          buildInputs = with pkgs; with python3Packages; [ pip setuptools (toPythonModule kicad-unstable-small.src) ];
        };
      }
    );
}
