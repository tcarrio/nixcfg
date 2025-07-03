{ mkBunDerivation, ... }:
let
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
in
mkBunDerivation {
  inherit (manifest) version;
  pname = "gqurl";
  src = ./.;
  bunNix = ./nix/bun.nix;
  index = manifest.main;
}
