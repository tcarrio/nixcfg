{ mkBunDerivation, ... }:
let
  manifest = builtins.fromJSON (builtins.readFile ./package.json);
  name = builtins.replaceStrings ["@" "/"] ["" "--"] manifest.name;
in
mkBunDerivation {
  inherit (manifest) version;
  inherit name;
  pname = name;
  src = ./.;
  bunNix = ./bun.nix;
  index = manifest.main;
}
