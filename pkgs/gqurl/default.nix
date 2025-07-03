{ mkBunDerivation, ... }:
let
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
in
mkBunDerivation {
  inherit (manifest) name version;
  pname = manifest.name;
  src = ./.;
  bunNix = ./bun.nix;
  index = manifest.main;
}
