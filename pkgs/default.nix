# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs, mkBunDerivation, nixvim }: {
  awsesh = pkgs.callPackage ./awsesh.nix { inherit pkgs; };
  gh-composer-auth = pkgs.callPackage ./gh-composer-auth.nix {};
  kube-rsync = pkgs.callPackage ./kube-rsync/default.nix { inherit pkgs; };
  # TODO: Fix non-Darwin build issue
  # mac-launcher = pkgs.callPackage ./mac-launcher.nix { inherit pkgs; };
  zeit = pkgs.callPackage ./zeit.nix { };
  gqurl = pkgs.callPackage ./gqurl/default.nix {
    inherit mkBunDerivation;
  };
  nixvim = pkgs.callPackage ./nixvim/default.nix {
    inherit nixvim pkgs;
  };
}
