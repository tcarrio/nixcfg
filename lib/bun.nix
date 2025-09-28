{ self, inputs, outputs, stateVersion, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.bun2nix.lib.${system}) mkBunDerivation;
in
{
  inherit mkBunDerivation;
  mkStandardBun = { path }:
    let
      manifest = builtins.fromJSON (builtins.readFile "${path}/package.json");
    in mkBunDerivation {
      inherit (manifest) version;
      pname = manifest.name;
      index = manifest.main;
      src = "${path}";
      bunNix = "${path}/bun.nix";
    };
}
