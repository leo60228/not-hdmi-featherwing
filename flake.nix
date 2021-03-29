{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgsUnstable.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, nixpkgsUnstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = {
          kicad-unstable = with pkgs; let
            kicad = callPackage "${nixpkgsUnstable}/pkgs/applications/science/electronics/kicad" {
              pname = "kicad-unstable";
              stable = false;
              srcs = let
                version = "2021-03-29";
              in {
                kicadVersion = version;
                kicad = fetchFromGitLab {
                  group = "kicad";
                  owner = "code";
                  repo = "kicad";
                  rev = "38c849bde7ef779f9ee43f7af2fd9e56b13008c6";
                  sha256 = "1k0m8h516l711bwyw0rk4il53wz2ap16vsq1i592fmzsfil3wb44";
                };
                libVersion = version;
                i18n = fetchFromGitLab {
                  group = "kicad";
                  owner = "code";
                  repo = "kicad-i18n";
                  rev = "e89d9a89bec59199c1ade56ee2556591412ab7b0";
                  sha256 = "04zaqyhj3qr4ymyd3k5vjpcna64j8klpsygcgjcv29s3rdi8glfl";
                };
                symbols = fetchFromGitLab {
                  group = "kicad";
                  owner = "libraries";
                  repo = "kicad-symbols";
                  rev = "e821243533520db253e42f9f84a60011b87b902d";
                  sha256 = "0vi6qyibfkjmm3dany8kvhp6nzjhyixmmp8w15icih47mz269qm6";
                };
                templates = fetchFromGitLab {
                  group = "kicad";
                  owner = "libraries";
                  repo = "kicad-templates";
                  rev = "073d1941c428242a563dcb5301ff5c7479fe9c71";
                  sha256 = "14p06m2zvlzzz2w74y83f2zml7mgv5dhy2nyfkpblanxawrzxv1x";
                };
                footprints = fetchFromGitLab {
                  group = "kicad";
                  owner = "libraries";
                  repo = "kicad-footprints";
                  rev = "9646bb7b4b215ccd65889b5a0c5b2e52be47b097";
                  sha256 = "1fvh2hyahjjmsivdblx1aaj9m2iz04z9wccz8h9kp3vzyrb3i17h";
                };
                packages3d = fetchFromGitLab {
                  group = "kicad";
                  owner = "libraries";
                  repo = "kicad-packages3d";
                  rev = "d8b7e8c56d535f4d7e46373bf24c754a8403da1f";
                  sha256 = "0dh8ixg0w43wzj5h3164dz6l1vl4llwxhi3qcdgj1lgvrs28aywd";
                };
              };
            };
            inherit (kicad.libraries) packages3d footprints;
          in
            kicad.overrideAttrs (oldAttrs: {
              makeWrapperArgs = (builtins.map (builtins.replaceStrings [ "KICAD_" ] [ "KICAD6_" ]) oldAttrs.makeWrapperArgs) ++ [
                "--set-default KICAD6_3DMODEL_DIR ${packages3d}/share/kicad/3dmodels"
                "--set-default KICAD6_FOOTPRINT_DIR ${footprints}/share/kicad/modules"
              ];
            });
          freecad = with pkgs; freecad.overrideAttrs (oldAttrs: {
            buildInputs = oldAttrs.buildInputs ++ (with python3Packages; [ ply ]);
          });
        };
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; with packages; [ kicad-unstable gerbv freecad blender python3 ];
          buildInputs = with pkgs; with python3Packages; with packages; [ pip setuptools (toPythonModule kicad-unstable.src) ];
        };
      }
    );
}
