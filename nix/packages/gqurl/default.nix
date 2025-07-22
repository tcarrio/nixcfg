{ inputs, system, ... }:
let
  inherit (inputs.bun2nix.lib.${system}) mkBunDerivation;
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
in
mkBunDerivation {
  inherit (manifest) version;
  pname = "gqurl";
  index = manifest.main;
  src = ./.;
  bunNix = ./bun.nix;
}
