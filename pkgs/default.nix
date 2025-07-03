# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { }, mkBunDerivation, nixvim }: {
  kube-rsync = pkgs.callPackage ./kube-rsync.nix { };
  zeit = pkgs.callPackage ./zeit.nix { };
  gqurl = pkgs.callPackage ./gqurl/default.nix {
    inherit mkBunDerivation;
  };
  nixvim = pkgs.callPackage ./nixvim/default.nix {
    inherit nixvim;
  gqurl-effect = pkgs.callPackage ./gqurl-effect/default.nix {
    inherit mkBunDerivation;
  };
}
