# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { }, mkBunDerivation }: {
  kube-rsync = pkgs.callPackage ./kube-rsync.nix { };
  zeit = pkgs.callPackage ./zeit.nix { };
  gqurl = pkgs.callPackage ./gqurl/default.nix {
    inherit mkBunDerivation;
  };
}
