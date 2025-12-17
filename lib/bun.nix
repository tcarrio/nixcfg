_:
{
  mkBunDerivation = bun2nix:
    { path }:
    let
      manifest = builtins.fromJSON (builtins.readFile "${path}/package.json");
    in
    bun2nix.mkDerivation {
      inherit (manifest) version;
      pname = manifest.name;
      index = manifest.main;
      src = "${path}";
      bunDeps = bun2nix.fetchBunDeps {
        bunNix = "${path}/bun.nix";
      };
    };
}
